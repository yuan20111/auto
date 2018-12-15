require 'spec_helper'

describe "Internal Project Access", feature: true  do
  let(:project) { create(:project, :internal) }

  let(:master) { create(:user) }
  let(:guest) { create(:user) }
  let(:reporter) { create(:user) }

  before do
    # full access
    project.team << [master, :master]

    # readonly
    project.team << [reporter, :reporter]
  end

  describe "Project should be internal" do
    subject { project }

    describe '#internal?' do
      subject { super().internal? }
      it { is_expected.to be_truthy }
    end
  end

  describe "GET /:project_path" do
    subject { project_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/tree/master" do
    subject { project_tree_path(project, project.repository.root_ref) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/commits/master" do
    subject { project_commits_path(project, project.repository.root_ref, limit: 1) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/commit/:sha" do
    subject { project_commit_path(project, project.repository.commit) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/compare" do
    subject { project_compare_index_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/team" do
    subject { project_team_index_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_denied_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/blob" do
    before do
      commit = project.repository.commit
      path = '.gitignore'
      @blob_path = project_blob_path(project, File.join(commit.id, path))
    end

    it { expect(@blob_path).to be_allowed_for master }
    it { expect(@blob_path).to be_allowed_for reporter }
    it { expect(@blob_path).to be_allowed_for :admin }
    it { expect(@blob_path).to be_allowed_for guest }
    it { expect(@blob_path).to be_allowed_for :user }
    it { expect(@blob_path).to be_denied_for :visitor }
  end

  describe "GET /:project_path/edit" do
    subject { edit_project_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_denied_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/deploy_keys" do
    subject { project_deploy_keys_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_denied_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/issues" do
    subject { project_issues_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/snippets" do
    subject { project_snippets_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/snippets/new" do
    subject { new_project_snippet_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/merge_requests" do
    subject { project_merge_requests_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/merge_requests/new" do
    subject { new_project_merge_request_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_denied_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/branches" do
    subject { project_branches_path(project) }

    before do
      # Speed increase
      allow_any_instance_of(Project).to receive(:branches).and_return([])
    end

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/tags" do
    subject { project_tags_path(project) }

    before do
      # Speed increase
      allow_any_instance_of(Project).to receive(:tags).and_return([])
    end

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_allowed_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_allowed_for guest }
    it { is_expected.to be_allowed_for :user }
    it { is_expected.to be_denied_for :visitor }
  end

  describe "GET /:project_path/hooks" do
    subject { project_hooks_path(project) }

    it { is_expected.to be_allowed_for master }
    it { is_expected.to be_denied_for reporter }
    it { is_expected.to be_allowed_for :admin }
    it { is_expected.to be_denied_for guest }
    it { is_expected.to be_denied_for :user }
    it { is_expected.to be_denied_for :visitor }
  end
end
