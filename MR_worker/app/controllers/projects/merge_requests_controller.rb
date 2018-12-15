require 'gitlab/satellite/satellite'

class Projects::MergeRequestsController < Projects::ApplicationController
  include Gitlab::ConfigHelper

  before_filter :module_enabled
  before_filter :merge_request, only: [:edit, :update, :show, :diffs, :automerge, :automerge_check, :ci_status]
  before_filter :closes_issues, only: [:edit, :update, :show, :diffs]
  before_filter :validates_merge_request, only: [:show, :diffs]
  before_filter :define_show_vars, only: [:show, :diffs]

  # Allow read any merge_request
  before_filter :authorize_read_merge_request!

  # Allow write(create) merge_request
  before_filter :authorize_write_merge_request!, only: [:new, :create]

  # Allow modify merge_request
  before_filter :authorize_modify_merge_request!, only: [:close, :edit, :update, :sort]

  def index
    @merge_requests = get_merge_requests_collection
    @merge_requests = @merge_requests.page(params[:page]).per(20)
  end

  def show
    @note_counts = Note.where(commit_id: @merge_request.commits.map(&:id)).
      group(:commit_id).count

    respond_to do |format|
      format.html
      format.json { render json: @merge_request }
      format.diff { render text: @merge_request.to_diff(current_user) }
      format.patch { render text: @merge_request.to_patch(current_user) }
    end
  end

  def diffs
    @commit = @merge_request.last_commit
    @comments_allowed = @reply_allowed = true
    @comments_target = {
      noteable_type: 'MergeRequest',
      noteable_id: @merge_request.id
    }
    @line_notes = @merge_request.notes.where("line_code is not null")

    respond_to do |format|
      format.html
      format.json { render json: { html: view_to_html_string("projects/merge_requests/show/_diffs") } }
    end
  end

  def new
    params[:merge_request] ||= ActionController::Parameters.new(source_project: @project)
    @merge_request = MergeRequests::BuildService.new(project, current_user, merge_request_params).execute

    @target_branches = if @merge_request.target_project
                         @merge_request.target_project.repository.branch_names
                       else
                         []
                       end

    @target_project = merge_request.target_project
    @source_project = merge_request.source_project
    @commits = @merge_request.compare_commits
    @commit = @merge_request.compare_commits.last
    @diffs = @merge_request.compare_diffs
    @note_counts = Note.where(commit_id: @commits.map(&:id)).
      group(:commit_id).count

  end

  def edit
    @source_project = @merge_request.source_project
    @target_project = @merge_request.target_project
    @target_branches = @merge_request.target_project.repository.branch_names
  end

  def create
    @target_branches ||= []
    @merge_request = MergeRequests::CreateService.new(project, current_user, merge_request_params).execute

    author = User.find_by(id: "#{@merge_request.author_id}")

    if @merge_request.valid? 
      redirect_to project_merge_request_path(@merge_request.target_project, @merge_request), notice: 'Merge request was successfully created.'

      ## 20 of every month is Time Point
      start_time = DateTime.new(@merge_request.created_at.year, @merge_request.created_at.month, 20)
      if @merge_request.created_at.to_i < start_time.to_i
        end_time = start_time
        start_time = end_time - 1.month
      else
        end_time = start_time + 1.month
      end
      file_path = "./log/#{start_time.year}#{start_time.month}#{start_time.day}-#{end_time.year}#{end_time.month}#{end_time.day}.txt"
      if File::exists?("#{file_path}")
        fl = File.open( "#{file_path}", "a+")
      else
        fl = File.new("#{file_path}", "a+")
        fl = File.open( "#{file_path}", "a+")
      end

      fl.write("#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#\n")
      fl.write("#{project.name}(##{@merge_request.iid})    #{author.name}\n")
      fl.write("#{@merge_request.title}\n")
      fl.write("#{@merge_request.description}")
      fl.write("#{@merge_request.to_diff(current_user)}".force_encoding("UTF-8"))
      fl.write("\n")
      fl.close
    else
      @source_project = @merge_request.source_project
      @target_project = @merge_request.target_project
      render action: "new"
    end

  end

  def update
    @merge_request = MergeRequests::UpdateService.new(project, current_user, merge_request_params).execute(@merge_request)

    if @merge_request.valid?
      respond_to do |format|
        format.js
        format.html do
          redirect_to [@merge_request.target_project, @merge_request], notice: 'Merge request was successfully updated.'
        end
      end
    else
      render "edit"
    end
  end


  def automerge_check
    if @merge_request.unchecked?
      @merge_request.check_if_can_be_merged
    end

    render json: { merge_status: @merge_request.merge_status_name }
  end

  def automerge
    #return access_denied! unless allowed_to_merge?
    #current_user = User.find_by(username: "root")
    current_user = User.find_by(id: "#{@merge_request.assignee_id}")

    if @merge_request.open? && @merge_request.can_be_merged?
      if ("#{@project.namespace.type}" == "Group")
        make_mr_note
      end
      AutoMergeWorker.perform_async(@merge_request.id, current_user.id, params)
      @status = true
    else
      @status = false
    end
  end

  def branch_from
    #This is always source
    @source_project = @merge_request.nil? ? @project : @merge_request.source_project
    @commit = @repository.commit(params[:ref]) if params[:ref].present?
  end

  def branch_to
    @target_project = selected_target_project
    @commit = @target_project.repository.commit(params[:ref]) if params[:ref].present?
  end

  def update_branches
    @target_project = selected_target_project
    @target_branches = @target_project.repository.branch_names

    respond_to do |format|
      format.js
    end
  end

  def ci_status
    ci_service = @merge_request.source_project.ci_service
    status = ci_service.commit_status(merge_request.last_commit.sha)

    if ci_service.respond_to?(:commit_coverage)
      coverage = ci_service.commit_coverage(merge_request.last_commit.sha)
    end

    response = {
      status: status,
      coverage: coverage
    }

    render json: response
  end

  protected

  def selected_target_project
    if @project.id.to_s == params[:target_project_id] || @project.forked_project_link.nil?
      @project
    else
      @project.forked_project_link.forked_from_project
    end
  end

  def merge_request
    @merge_request ||= @project.merge_requests.find_by!(iid: params[:id])
  end

  def closes_issues
    @closes_issues ||= @merge_request.closes_issues
  end

  def authorize_modify_merge_request!
    return render_404 unless can?(current_user, :modify_merge_request, @merge_request)
  end

  def authorize_admin_merge_request!
    return render_404 unless can?(current_user, :admin_merge_request, @merge_request)
  end

  def module_enabled
    return render_404 unless @project.merge_requests_enabled
  end

  def validates_merge_request
    # If source project was removed (Ex. mr from fork to origin)
    return invalid_mr unless @merge_request.source_project

    # Show git not found page
    # if there is no saved commits between source & target branch
    if @merge_request.commits.blank?
      # and if target branch doesn't exist
      return invalid_mr unless @merge_request.target_branch_exists?

      # or if source branch doesn't exist
      return invalid_mr unless @merge_request.source_branch_exists?
    end
  end

  def define_show_vars
    # Build a note object for comment form
    @note = @project.notes.new(noteable: @merge_request)
    @notes = @merge_request.mr_and_commit_notes.inc_author.fresh
    @discussions = Note.discussions_from_notes(@notes)
    @noteable = @merge_request

    # Get commits from repository
    # or from cache if already merged
    @commits = @merge_request.commits

    @merge_request_diff = @merge_request.merge_request_diff
    @allowed_to_merge = allowed_to_merge?
    if @project.pam_enabled || @project.am_enabled
      @show_merge_controls = @merge_request.open? && @commits.any?
    else
      @show_merge_controls = @merge_request.open? && @commits.any? && @allowed_to_merge
    end
    @source_branch = @merge_request.source_project.repository.find_branch(@merge_request.source_branch).try(:name)
    @allowed_to_automerge = mr_auto_merge?

    if @merge_request.locked_long_ago?
      @merge_request.unlock_mr
      @merge_request.close
    end
  end

  def mr_auto_merge?
    if project.merge_requests_enabled
       true
    else
       false
    end
  end

  def allowed_to_merge?
    allowed_to_push_code?(project, @merge_request.target_branch)
  end

  def invalid_mr
    # Render special view for MR with removed source or target branch
    render 'invalid'
  end

  def allowed_to_push_code?(project, branch)
    ::Gitlab::GitAccess.can_push_to_branch?(current_user, project, branch)
  end

  def merge_request_params
    params.require(:merge_request).permit(
      :title, :assignee_id, :source_project_id, :source_branch,
      :target_project_id, :target_branch, :milestone_id,
      :state_event, :description, :task_num, label_ids: []
    )
  end

  def make_mr_note
    #mr_url: /namespace/project/merge_requests/iid
    mr_url = project_merge_request_path(@merge_request.target_project, @merge_request)
    array = mr_url.split("\/")
    #pro_path: namespace/project
    pro_path = @merge_request.source_project.path_with_namespace
    # author name
    strobj = User.find(@merge_request.author_id)

    ## Make note File, File path defined by customer
    file_path = "./precompile/#{@merge_request.source_project.name}-#{array[4]}.txt"
    fl = File.open( "#{file_path}", "w+")

    fl.write("分    支 : git@#{gitlab_config.host}:#{pro_path}.git #{@merge_request.target_branch}\n")
    fl.write("邮    箱 : #{strobj.notification_email}\n")
    fl.write("修 改 人 : #{strobj.name}\n")
    fl.write("软 件 包 : #{@merge_request.source_project.name}\n")
    fl.write("描    述 : #{@merge_request.title}\n")
    fl.write("修复 Bug :\n")
    fl.write("合并 Req : http://#{gitlab_config.host}#{mr_url}\n")
    fl.close
  end

end
