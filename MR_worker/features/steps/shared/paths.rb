module SharedPaths
  include Spinach::DSL
  include RepoHelpers
  include DashboardHelper

  step 'I visit new project page' do
    visit new_project_path
  end

  # ----------------------------------------
  # User
  # ----------------------------------------

  step 'I visit user "John Doe" page' do
    visit user_path("john_doe")
  end

  # ----------------------------------------
  # Group
  # ----------------------------------------

  step 'I visit group "Owned" page' do
    visit group_path(Group.find_by(name:"Owned"))
  end

  step 'I visit group "Owned" issues page' do
    visit issues_group_path(Group.find_by(name:"Owned"))
  end

  step 'I visit group "Owned" merge requests page' do
    visit merge_requests_group_path(Group.find_by(name:"Owned"))
  end

  step 'I visit group "Owned" members page' do
    visit members_group_path(Group.find_by(name:"Owned"))
  end

  step 'I visit group "Owned" settings page' do
    visit edit_group_path(Group.find_by(name:"Owned"))
  end

  step 'I visit group "Guest" page' do
    visit group_path(Group.find_by(name:"Guest"))
  end

  step 'I visit group "Guest" issues page' do
    visit issues_group_path(Group.find_by(name:"Guest"))
  end

  step 'I visit group "Guest" merge requests page' do
    visit merge_requests_group_path(Group.find_by(name:"Guest"))
  end

  step 'I visit group "Guest" members page' do
    visit members_group_path(Group.find_by(name:"Guest"))
  end

  step 'I visit group "Guest" settings page' do
    visit edit_group_path(Group.find_by(name:"Guest"))
  end

  # ----------------------------------------
  # Dashboard
  # ----------------------------------------

  step 'I visit dashboard page' do
    visit dashboard_path
  end

  step 'I visit dashboard projects page' do
    visit projects_dashboard_path
  end

  step 'I visit dashboard issues page' do
    visit assigned_issues_dashboard_path
  end

  step 'I visit dashboard merge requests page' do
    visit assigned_mrs_dashboard_path
  end

  step 'I visit dashboard search page' do
    visit search_path
  end

  step 'I visit dashboard help page' do
    visit help_path
  end

  # ----------------------------------------
  # Profile
  # ----------------------------------------

  step 'I visit profile page' do
    visit profile_path
  end

  step 'I visit profile applications page' do
    visit applications_profile_path
  end

  step 'I visit profile password page' do
    visit edit_profile_password_path
  end

  step 'I visit profile account page' do
    visit profile_account_path
  end

  step 'I visit profile SSH keys page' do
    visit profile_keys_path
  end

  step 'I visit profile design page' do
    visit design_profile_path
  end

  step 'I visit profile history page' do
    visit history_profile_path
  end

  step 'I visit profile groups page' do
    visit profile_groups_path
  end

  step 'I should be redirected to the profile groups page' do
    current_path.should == profile_groups_path
  end

  # ----------------------------------------
  # Admin
  # ----------------------------------------

  step 'I visit admin page' do
    visit admin_root_path
  end

  step 'I visit admin projects page' do
    visit admin_projects_path
  end

  step 'I visit admin users page' do
    visit admin_users_path
  end

  step 'I visit admin logs page' do
    visit admin_logs_path
  end

  step 'I visit admin messages page' do
    visit admin_broadcast_messages_path
  end

  step 'I visit admin hooks page' do
    visit admin_hooks_path
  end

  step 'I visit admin Resque page' do
    visit admin_background_jobs_path
  end

  step 'I visit admin groups page' do
    visit admin_groups_path
  end

  step 'I visit admin teams page' do
    visit admin_teams_path
  end

  step 'I visit admin settings page' do
    visit admin_application_settings_path
  end

  step 'I visit applications page' do
    visit admin_applications_path
  end

  # ----------------------------------------
  # Generic Project
  # ----------------------------------------

  step "I visit my project's home page" do
    visit project_path(@project)
  end

  step "I visit my project's settings page" do
    visit edit_project_path(@project)
  end

  step "I visit my project's files page" do
    visit project_tree_path(@project, root_ref)
  end

  step 'I visit a binary file in the repo' do
    visit project_blob_path(@project, File.join(
      root_ref, 'files/images/logo-black.png'))
  end

  step "I visit my project's commits page" do
    visit project_commits_path(@project, root_ref, {limit: 5})
  end

  step "I visit my project's commits page for a specific path" do
    visit project_commits_path(@project, root_ref + "/app/models/project.rb", {limit: 5})
  end

  step 'I visit my project\'s commits stats page' do
    visit stats_project_repository_path(@project)
  end

  step "I visit my project's network page" do
    # Stub Graph max_size to speed up test (10 commits vs. 650)
    Network::Graph.stub(max_count: 10)

    visit project_network_path(@project, root_ref)
  end

  step "I visit my project's issues page" do
    visit project_issues_path(@project)
  end

  step "I visit my project's merge requests page" do
    visit project_merge_requests_path(@project)
  end

  step "I visit my project's wiki page" do
    visit project_wiki_path(@project, :home)
  end

  step 'I visit project hooks page' do
    visit project_hooks_path(@project)
  end

  step 'I visit project deploy keys page' do
    visit project_deploy_keys_path(@project)
  end

  # ----------------------------------------
  # "Shop" Project
  # ----------------------------------------

  step 'I visit project "Shop" page' do
    visit project_path(project)
  end

  step 'I visit project "Forked Shop" merge requests page' do
    visit project_merge_requests_path(@forked_project)
  end

  step 'I visit edit project "Shop" page' do
    visit edit_project_path(project)
  end

  step 'I visit project branches page' do
    visit project_branches_path(@project)
  end

  step 'I visit project protected branches page' do
    visit project_protected_branches_path(@project)
  end

  step 'I visit compare refs page' do
    visit project_compare_index_path(@project)
  end

  step 'I visit project commits page' do
    visit project_commits_path(@project, root_ref, {limit: 5})
  end

  step 'I visit project commits page for stable branch' do
    visit project_commits_path(@project, 'stable', {limit: 5})
  end

  step 'I visit project source page' do
    visit project_tree_path(@project, root_ref)
  end

  step 'I visit blob file from repo' do
    visit project_blob_path(@project, File.join(sample_commit.id, sample_blob.path))
  end

  step 'I visit ".gitignore" file in repo' do
    visit project_blob_path(@project, File.join(root_ref, '.gitignore'))
  end

  step 'I am on the new file page' do
    current_path.should eq(project_create_blob_path(@project, root_ref))
  end

  step 'I am on the ".gitignore" edit file page' do
    current_path.should eq(project_edit_blob_path(
      @project, File.join(root_ref, '.gitignore')))
  end

  step 'I visit project source page for "6d39438"' do
    visit project_tree_path(@project, "6d39438")
  end

  step 'I visit project source page for' \
       ' "6d394385cf567f80a8fd85055db1ab4c5295806f"' do
    visit project_tree_path(@project,
                            '6d394385cf567f80a8fd85055db1ab4c5295806f')
  end

  step 'I visit project tags page' do
    visit project_tags_path(@project)
  end

  step 'I visit project commit page' do
    visit project_commit_path(@project, sample_commit.id)
  end

  step 'I visit project "Shop" issues page' do
    visit project_issues_path(project)
  end

  step 'I visit issue page "Release 0.4"' do
    issue = Issue.find_by(title: "Release 0.4")
    visit project_issue_path(issue.project, issue)
  end

  step 'I visit issue page "Tasks-open"' do
    issue = Issue.find_by(title: 'Tasks-open')
    visit project_issue_path(issue.project, issue)
  end

  step 'I visit issue page "Tasks-closed"' do
    issue = Issue.find_by(title: 'Tasks-closed')
    visit project_issue_path(issue.project, issue)
  end

  step 'I visit project "Shop" labels page' do
    project = Project.find_by(name: 'Shop')
    visit project_labels_path(project)
  end

  step 'I visit project "Forum" labels page' do
    project = Project.find_by(name: 'Forum')
    visit project_labels_path(project)
  end

  step 'I visit project "Shop" new label page' do
    project = Project.find_by(name: 'Shop')
    visit new_project_label_path(project)
  end

  step 'I visit project "Forum" new label page' do
    project = Project.find_by(name: 'Forum')
    visit new_project_label_path(project)
  end

  step 'I visit merge request page "Bug NS-04"' do
    mr = MergeRequest.find_by(title: "Bug NS-04")
    visit project_merge_request_path(mr.target_project, mr)
  end

  step 'I visit merge request page "Bug NS-05"' do
    mr = MergeRequest.find_by(title: "Bug NS-05")
    visit project_merge_request_path(mr.target_project, mr)
  end

  step 'I visit merge request page "MR-task-open"' do
    mr = MergeRequest.find_by(title: 'MR-task-open')
    visit project_merge_request_path(mr.target_project, mr)
  end

  step 'I visit merge request page "MR-task-closed"' do
    mr = MergeRequest.find_by(title: 'MR-task-closed')
    visit project_merge_request_path(mr.target_project, mr)
  end

  step 'I visit project "Shop" merge requests page' do
    visit project_merge_requests_path(project)
  end

  step 'I visit forked project "Shop" merge requests page' do
    visit project_merge_requests_path(project)
  end

  step 'I visit project "Shop" milestones page' do
    visit project_milestones_path(project)
  end

  step 'I visit project "Shop" team page' do
    visit project_team_index_path(project)
  end

  step 'I visit project wiki page' do
    visit project_wiki_path(@project, :home)
  end

  # ----------------------------------------
  # Visibility Projects
  # ----------------------------------------

  step 'I visit project "Community" page' do
    project = Project.find_by(name: "Community")
    visit project_path(project)
  end

  step 'I visit project "Community" source page' do
    project = Project.find_by(name: 'Community')
    visit project_tree_path(project, root_ref)
  end

  step 'I visit project "Internal" page' do
    project = Project.find_by(name: "Internal")
    visit project_path(project)
  end

  step 'I visit project "Enterprise" page' do
    project = Project.find_by(name: "Enterprise")
    visit project_path(project)
  end

  # ----------------------------------------
  # Empty Projects
  # ----------------------------------------

  step "I visit empty project page" do
    project = Project.find_by(name: "Empty Public Project")
    visit project_path(project)
  end

  # ----------------------------------------
  # Public Projects
  # ----------------------------------------

  step 'I visit the public projects area' do
    visit explore_projects_path
  end

   step 'I visit the explore trending projects' do
     visit trending_explore_projects_path
   end

   step 'I visit the explore starred projects' do
     visit starred_explore_projects_path
   end

  step 'I visit the public groups area' do
    visit explore_groups_path
  end

  # ----------------------------------------
  # Snippets
  # ----------------------------------------

  step 'I visit project "Shop" snippets page' do
    visit project_snippets_path(project)
  end

  step 'I visit snippets page' do
    visit snippets_path
  end

  step 'I visit new snippet page' do
    visit new_snippet_path
  end

  def root_ref
    @project.repository.root_ref
  end

  def project
    Project.find_by!(name: 'Shop')
  end

  # ----------------------------------------
  # Errors
  # ----------------------------------------

  step 'page status code should be 404' do
    status_code.should == 404
  end
end
