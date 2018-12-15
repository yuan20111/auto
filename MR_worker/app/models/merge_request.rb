# == Schema Information
#
# Table name: merge_requests
#
#  id                :integer          not null, primary key
#  target_branch     :string(255)      not null
#  source_branch     :string(255)      not null
#  source_project_id :integer          not null
#  author_id         :integer
#  assignee_id       :integer
#  title             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  milestone_id      :integer
#  state             :string(255)
#  merge_status      :string(255)
#  target_project_id :integer          not null
#  iid               :integer
#  description       :text
#  position          :integer          default(0)
#  locked_at         :datetime
#

require Rails.root.join("app/models/commit")
require Rails.root.join("lib/static_model")

class MergeRequest < ActiveRecord::Base
  include Issuable
  include Taskable
  include InternalId
  include Sortable
  include Gitlab::ConfigHelper

  belongs_to :target_project, foreign_key: :target_project_id, class_name: "Project"
  belongs_to :source_project, foreign_key: :source_project_id, class_name: "Project"

  has_one :merge_request_diff, dependent: :destroy

  after_create :create_merge_request_diff
  after_update :update_merge_request_diff

  delegate :commits, :diffs, :last_commit, :last_commit_short_sha, to: :merge_request_diff, prefix: nil

  attr_accessor :should_remove_source_branch

  # When this attribute is true some MR validation is ignored
  # It allows us to close or modify broken merge requests
  attr_accessor :allow_broken

  # Temporary fields to store compare vars
  # when creating new merge request
  attr_accessor :can_be_created, :compare_failed,
    :compare_commits, :compare_diffs

  state_machine :state, initial: :opened do
    event :close do
      transition [:reopened, :opened] => :closed
    end

    event :merge do
      transition [:reopened, :opened, :locked] => :merged
    end

    event :reopen do
      transition closed: :reopened
    end

    event :lock_mr do
      transition [:reopened, :opened] => :locked
    end

    event :unlock_mr do
      transition locked: :reopened
    end

    after_transition any => :locked do |merge_request, transition|
      merge_request.locked_at = Time.now
      merge_request.save
    end

    after_transition locked: (any - :locked) do |merge_request, transition|
      merge_request.locked_at = nil
      merge_request.save
    end

    state :opened
    state :reopened
    state :closed
    state :merged
    state :locked
  end

  state_machine :merge_status, initial: :unchecked do
    event :mark_as_unchecked do
      transition [:can_be_merged, :cannot_be_merged] => :unchecked
    end

    event :mark_as_mergeable do
      transition unchecked: :can_be_merged
    end

    event :mark_as_unmergeable do
      transition unchecked: :cannot_be_merged
    end

    state :unchecked
    state :can_be_merged
    state :cannot_be_merged
  end

  validates :source_project, presence: true, unless: :allow_broken
  validates :source_branch, presence: true
  validates :target_project, presence: true
  validates :target_branch, presence: true
  validate :validate_branches
  validate :validate_fork
  validate :validate_version_num?, on: :create, if: :include_changelog?
  validate :validate_mr_validation?, on: :create  

  scope :of_group, ->(group) { where("source_project_id in (:group_project_ids) OR target_project_id in (:group_project_ids)", group_project_ids: group.project_ids) }
  scope :of_user_team, ->(team) { where("(source_project_id in (:team_project_ids) OR target_project_id in (:team_project_ids) AND assignee_id in (:team_member_ids))", team_project_ids: team.project_ids, team_member_ids: team.member_ids) }
  scope :merged, -> { with_state(:merged) }
  scope :by_branch, ->(branch_name) { where("(source_branch LIKE :branch) OR (target_branch LIKE :branch)", branch: branch_name) }
  scope :cared, ->(user) { where('assignee_id = :user OR author_id = :user', user: user.id) }
  scope :by_milestone, ->(milestone) { where(milestone_id: milestone) }
  scope :in_projects, ->(project_ids) { where("source_project_id in (:project_ids) OR target_project_id in (:project_ids)", project_ids: project_ids) }
  scope :of_projects, ->(ids) { where(target_project_id: ids) }
  # Closed scope for merge request should return
  # both merged and closed mr's
  scope :closed, -> { with_states(:closed, :merged) }
  scope :declined, -> { with_states(:closed) }


  def validate_branches
    if target_project == source_project && target_branch == source_branch
      errors.add :branch_conflict, "You can not use same project/branch for source and target"
    end

    if opened? || reopened?
      similar_mrs = self.target_project.merge_requests.where(source_branch: source_branch, target_branch: target_branch, source_project_id: source_project.id).opened
      similar_mrs = similar_mrs.where('id not in (?)', self.id) if self.id
      if similar_mrs.any?
        errors.add :validate_branches,
                   "Cannot Create: This merge request already exists: #{
                   similar_mrs.pluck(:title)
                   }"
      end
    end
  end

  def validate_fork
    return true unless target_project && source_project

    if target_project == source_project
      true
    else
      # If source and target projects are different
      # we should check if source project is actually a fork of target project
      if source_project.forked_from?(target_project)
        true
      else
        errors.add :validate_fork,
                   'Source project is not a fork of target project'
      end
    end
  end


  def update_merge_request_diff
    if source_branch_changed? || target_branch_changed?
      reload_code
      mark_as_unchecked
    end
  end

  def reload_code
    if merge_request_diff && open?
      merge_request_diff.reload_content
    end
  end

  def check_if_can_be_merged
    if Gitlab::Satellite::MergeAction.new(self.author, self).can_be_merged?
      mark_as_mergeable
    else
      mark_as_unmergeable
    end
  end

  def merge_event
    self.target_project.events.where(target_id: self.id, target_type: "MergeRequest", action: Event::MERGED).last
  end

  def closed_event
    self.target_project.events.where(target_id: self.id, target_type: "MergeRequest", action: Event::CLOSED).last
  end

  def automerge!(current_user, commit_message = nil)
    if MergeRequests::AutoMergeService.
      new(target_project, current_user).
      execute(self, commit_message)

      if ("#{project.namespace.type}" == "Group")
        scp_mr_info("./precompile/#{target_project.name}-#{iid}.txt")
      end
      true
    else
      false
    end
  end

  def open?
    opened? || reopened?
  end

  def mr_and_commit_notes
    # Fetch comments only from last 100 commits
    commits_for_notes_limit = 100
    commit_ids = commits.last(commits_for_notes_limit).map(&:id)

    project.notes.where(
      "(noteable_type = 'MergeRequest' AND noteable_id = :mr_id) OR (noteable_type = 'Commit' AND commit_id IN (:commit_ids))",
      mr_id: id,
      commit_ids: commit_ids
    )
  end

  # Returns the raw diff for this merge request
  #
  # see "git diff"
  def to_diff(current_user)
    Gitlab::Satellite::MergeAction.new(current_user, self).diff_in_satellite
  end

  # Returns the commit as a series of email patches.
  #
  # see "git format-patch"
  def to_patch(current_user)
    Gitlab::Satellite::MergeAction.new(current_user, self).format_patch
  end

  def hook_attrs
    attrs = {
      source: source_project.hook_attrs,
      target: target_project.hook_attrs,
      last_commit: nil
    }

    unless last_commit.nil?
      attrs.merge!(last_commit: last_commit.hook_attrs(source_project))
    end

    attributes.merge!(attrs)
  end

  def for_fork?
    target_project != source_project
  end

  def project
    target_project
  end

  # Return the set of issues that will be closed if this merge request is accepted.
  def closes_issues
    if target_branch == project.default_branch
      issues = commits.flat_map { |c| c.closes_issues(project) }
      issues.push(*Gitlab::ClosingIssueExtractor.
                  closed_by_message_in_project(description, project))
      issues.uniq.sort_by(&:id)
    else
      []
    end
  end

  # Mentionable override.
  def gfm_reference
    "merge request !#{iid}"
  end

  def target_project_path
    if target_project
      target_project.path_with_namespace
    else
      "(removed)"
    end
  end

  def source_project_path
    if source_project
      source_project.path_with_namespace
    else
      "(removed)"
    end
  end

  def source_project_namespace
    if source_project && source_project.namespace
      source_project.namespace.path
    else
      "(removed)"
    end
  end

  def target_project_namespace
    if target_project && target_project.namespace
      target_project.namespace.path
    else
      "(removed)"
    end
  end

  def source_branch_exists?
    return false unless self.source_project

    self.source_project.repository.branch_names.include?(self.source_branch)
  end

  def target_branch_exists?
    return false unless self.target_project

    self.target_project.repository.branch_names.include?(self.target_branch)
  end

  # Reset merge request events cache
  #
  # Since we do cache @event we need to reset cache in special cases:
  # * when a merge request is updated
  # Events cache stored like  events/23-20130109142513.
  # The cache key includes updated_at timestamp.
  # Thus it will automatically generate a new fragment
  # when the event is updated because the key changes.
  def reset_events_cache
    Event.reset_event_cache_for(self)
  end

  def merge_commit_message
    message = "Merge branch '#{source_branch}' into '#{target_branch}'"
    message << "\n\n"
    message << title.to_s
    message << "\n\n"
    message << description.to_s
    message << "\n\n"
    message << "See merge request !#{iid}"
    message
  end

  # Return array of possible target branches
  # depends on target project of MR
  def target_branches
    if target_project.nil?
      []
    else
      target_project.repository.branch_names
    end
  end

  # Return array of possible source branches
  # depends on source project of MR
  def source_branches
    if source_project.nil?
      []
    else
      source_project.repository.branch_names
    end
  end

  def locked_long_ago?
    locked_at && locked_at < (Time.now - 1.day)
  end

   # check user can accept merge reuqest?
  def check_user_power?(current_user)
    if (current_user.id == project.creator_id) || (project.project_master_member?(current_user.id)) || (project.namespace.group_master_or_owner?(current_user.id))
      return true
    else
      return false
    end
  end

  ## run shell, send compile command to compiler
  def scp_mr_info(file_path)
    logger.debug `./precompile/cp.sh #{file_path}`
    logger.debug $?
  end

  # judge target_branch is root_ref?
  def target_branch_is_root_ref?
    if target_project.repository.root_ref == target_branch
      true
    else
      false
    end
  end

  # ls files of master in satellite
  def include_changelog?
    return false unless target_branch_is_root_ref?

    lsfiles = Gitlab::Satellite::MergeAction.new(self.author, self).lsfiles_in_satellite

    strarr = lsfiles.scan(/.*debian\/changelog$/)
    len = strarr.size
    if len > 0
      true
    else
      false
    end
  end

 protected
  ######## verify merge conflict and version 
  def validate_version_num?
    diffstr = Gitlab::Satellite::MergeAction.new(self.author, self).diff_in_satellite
     
    strarr = diffstr.scan(/^diff --git.*debian\/changelog$/)
    len = strarr.size
    if len > 0
      logger.debug "Validate version number successfully"
      true
    else
      logger.error "Validate version number fail"
      errors.add :Changelog, "须做修改，填写新版本号."
      false
    end
  end

  def validate_mr_validation?
    if Gitlab::Satellite::MergeAction.new(self.author, self).can_be_merged?
      logger.debug "Validate merge request conflict successfully"
      true
    else
      logger.error "Validate merge request conflict fail"
      errors.add :MR, "源分支和目标分支有冲突." 
      false
    end
  end

##################################
end