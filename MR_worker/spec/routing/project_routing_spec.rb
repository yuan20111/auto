require 'spec_helper'

# Shared examples for a resource inside a Project
#
# By default it tests all the default REST actions: index, create, new, edit,
# show, update, and destroy. You can remove actions by customizing the
# `actions` variable.
#
# It also expects a `controller` variable to be available which defines both
# the path to the resource as well as the controller name.
#
# Examples
#
#   # Default behavior
#   it_behaves_like 'RESTful project resources' do
#     let(:controller) { 'issues' }
#   end
#
#   # Customizing actions
#   it_behaves_like 'RESTful project resources' do
#     let(:actions)    { [:index] }
#     let(:controller) { 'issues' }
#   end
shared_examples 'RESTful project resources' do
  let(:actions) { [:index, :create, :new, :edit, :show, :update, :destroy] }

  it 'to #index' do
    expect(get("/gitlab/gitlabhq/#{controller}")).to route_to("projects/#{controller}#index", project_id: 'gitlab/gitlabhq') if actions.include?(:index)
  end

  it 'to #create' do
    expect(post("/gitlab/gitlabhq/#{controller}")).to route_to("projects/#{controller}#create", project_id: 'gitlab/gitlabhq') if actions.include?(:create)
  end

  it 'to #new' do
    expect(get("/gitlab/gitlabhq/#{controller}/new")).to route_to("projects/#{controller}#new", project_id: 'gitlab/gitlabhq') if actions.include?(:new)
  end

  it 'to #edit' do
    expect(get("/gitlab/gitlabhq/#{controller}/1/edit")).to route_to("projects/#{controller}#edit", project_id: 'gitlab/gitlabhq', id: '1') if actions.include?(:edit)
  end

  it 'to #show' do
    expect(get("/gitlab/gitlabhq/#{controller}/1")).to route_to("projects/#{controller}#show", project_id: 'gitlab/gitlabhq', id: '1') if actions.include?(:show)
  end

  it 'to #update' do
    expect(put("/gitlab/gitlabhq/#{controller}/1")).to route_to("projects/#{controller}#update", project_id: 'gitlab/gitlabhq', id: '1') if actions.include?(:update)
  end

  it 'to #destroy' do
    expect(delete("/gitlab/gitlabhq/#{controller}/1")).to route_to("projects/#{controller}#destroy", project_id: 'gitlab/gitlabhq', id: '1') if actions.include?(:destroy)
  end
end

#                 projects POST   /projects(.:format)     projects#create
#              new_project GET    /projects/new(.:format) projects#new
#            files_project GET    /:id/files(.:format)    projects#files
#             edit_project GET    /:id/edit(.:format)     projects#edit
#                  project GET    /:id(.:format)          projects#show
#                          PUT    /:id(.:format)          projects#update
#                          DELETE /:id(.:format)          projects#destroy
# markdown_preview_project POST   /:id/markdown_preview(.:format) projects#markdown_preview
describe ProjectsController, 'routing' do
  it 'to #create' do
    expect(post('/projects')).to route_to('projects#create')
  end

  it 'to #new' do
    expect(get('/projects/new')).to route_to('projects#new')
  end

  it 'to #edit' do
    expect(get('/gitlab/gitlabhq/edit')).to route_to('projects#edit', id: 'gitlab/gitlabhq')
  end

  it 'to #autocomplete_sources' do
    expect(get('/gitlab/gitlabhq/autocomplete_sources')).to route_to('projects#autocomplete_sources', id: 'gitlab/gitlabhq')
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq')).to route_to('projects#show', id: 'gitlab/gitlabhq')
  end

  it 'to #update' do
    expect(put('/gitlab/gitlabhq')).to route_to('projects#update', id: 'gitlab/gitlabhq')
  end

  it 'to #destroy' do
    expect(delete('/gitlab/gitlabhq')).to route_to('projects#destroy', id: 'gitlab/gitlabhq')
  end

  it 'to #markdown_preview' do
    expect(post('/gitlab/gitlabhq/markdown_preview')).to(
      route_to('projects#markdown_preview', id: 'gitlab/gitlabhq')
    )
  end
end

#  pages_project_wikis GET    /:project_id/wikis/pages(.:format)       projects/wikis#pages
# history_project_wiki GET    /:project_id/wikis/:id/history(.:format) projects/wikis#history
#        project_wikis POST   /:project_id/wikis(.:format)             projects/wikis#create
#    edit_project_wiki GET    /:project_id/wikis/:id/edit(.:format)    projects/wikis#edit
#         project_wiki GET    /:project_id/wikis/:id(.:format)         projects/wikis#show
#                      DELETE /:project_id/wikis/:id(.:format)         projects/wikis#destroy
describe Projects::WikisController, 'routing' do
  it 'to #pages' do
    expect(get('/gitlab/gitlabhq/wikis/pages')).to route_to('projects/wikis#pages', project_id: 'gitlab/gitlabhq')
  end

  it 'to #history' do
    expect(get('/gitlab/gitlabhq/wikis/1/history')).to route_to('projects/wikis#history', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:create, :edit, :show, :destroy] }
    let(:controller) { 'wikis' }
  end
end

# branches_project_repository GET    /:project_id/repository/branches(.:format) projects/repositories#branches
#     tags_project_repository GET    /:project_id/repository/tags(.:format)     projects/repositories#tags
#  archive_project_repository GET    /:project_id/repository/archive(.:format)  projects/repositories#archive
#     edit_project_repository GET    /:project_id/repository/edit(.:format)     projects/repositories#edit
describe Projects::RepositoriesController, 'routing' do
  it 'to #archive' do
    expect(get('/gitlab/gitlabhq/repository/archive')).to route_to('projects/repositories#archive', project_id: 'gitlab/gitlabhq')
  end

  it 'to #archive format:zip' do
    expect(get('/gitlab/gitlabhq/repository/archive.zip')).to route_to('projects/repositories#archive', project_id: 'gitlab/gitlabhq', format: 'zip')
  end

  it 'to #archive format:tar.bz2' do
    expect(get('/gitlab/gitlabhq/repository/archive.tar.bz2')).to route_to('projects/repositories#archive', project_id: 'gitlab/gitlabhq', format: 'tar.bz2')
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq/repository')).to route_to('projects/repositories#show', project_id: 'gitlab/gitlabhq')
  end
end

describe Projects::BranchesController, 'routing' do
  it 'to #branches' do
    expect(get('/gitlab/gitlabhq/branches')).to route_to('projects/branches#index', project_id: 'gitlab/gitlabhq')
    expect(delete('/gitlab/gitlabhq/branches/feature%2345')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature#45')
    expect(delete('/gitlab/gitlabhq/branches/feature%2B45')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature+45')
    expect(delete('/gitlab/gitlabhq/branches/feature@45')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature@45')
    expect(delete('/gitlab/gitlabhq/branches/feature%2345/foo/bar/baz')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature#45/foo/bar/baz')
    expect(delete('/gitlab/gitlabhq/branches/feature%2B45/foo/bar/baz')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature+45/foo/bar/baz')
    expect(delete('/gitlab/gitlabhq/branches/feature@45/foo/bar/baz')).to route_to('projects/branches#destroy', project_id: 'gitlab/gitlabhq', id: 'feature@45/foo/bar/baz')
  end
end

describe Projects::TagsController, 'routing' do
  it 'to #tags' do
    expect(get('/gitlab/gitlabhq/tags')).to route_to('projects/tags#index', project_id: 'gitlab/gitlabhq')
    expect(delete('/gitlab/gitlabhq/tags/feature%2345')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature#45')
    expect(delete('/gitlab/gitlabhq/tags/feature%2B45')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature+45')
    expect(delete('/gitlab/gitlabhq/tags/feature@45')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature@45')
    expect(delete('/gitlab/gitlabhq/tags/feature%2345/foo/bar/baz')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature#45/foo/bar/baz')
    expect(delete('/gitlab/gitlabhq/tags/feature%2B45/foo/bar/baz')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature+45/foo/bar/baz')
    expect(delete('/gitlab/gitlabhq/tags/feature@45/foo/bar/baz')).to route_to('projects/tags#destroy', project_id: 'gitlab/gitlabhq', id: 'feature@45/foo/bar/baz')
  end
end


#     project_deploy_keys GET    /:project_id/deploy_keys(.:format)          deploy_keys#index
#                         POST   /:project_id/deploy_keys(.:format)          deploy_keys#create
#  new_project_deploy_key GET    /:project_id/deploy_keys/new(.:format)      deploy_keys#new
# edit_project_deploy_key GET    /:project_id/deploy_keys/:id/edit(.:format) deploy_keys#edit
#      project_deploy_key GET    /:project_id/deploy_keys/:id(.:format)      deploy_keys#show
#                         PUT    /:project_id/deploy_keys/:id(.:format)      deploy_keys#update
#                         DELETE /:project_id/deploy_keys/:id(.:format)      deploy_keys#destroy
describe Projects::DeployKeysController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:controller) { 'deploy_keys' }
  end
end

# project_protected_branches GET    /:project_id/protected_branches(.:format)     protected_branches#index
#                            POST   /:project_id/protected_branches(.:format)     protected_branches#create
#   project_protected_branch DELETE /:project_id/protected_branches/:id(.:format) protected_branches#destroy
describe Projects::ProtectedBranchesController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:index, :create, :destroy] }
    let(:controller) { 'protected_branches' }
  end
end

#    switch_project_refs GET    /:project_id/refs/switch(.:format)              refs#switch
#  logs_tree_project_ref GET    /:project_id/refs/:id/logs_tree(.:format)       refs#logs_tree
#  logs_file_project_ref GET    /:project_id/refs/:id/logs_tree/:path(.:format) refs#logs_tree
describe Projects::RefsController, 'routing' do
  it 'to #switch' do
    expect(get('/gitlab/gitlabhq/refs/switch')).to route_to('projects/refs#switch', project_id: 'gitlab/gitlabhq')
  end

  it 'to #logs_tree' do
    expect(get('/gitlab/gitlabhq/refs/stable/logs_tree')).to             route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'stable')
    expect(get('/gitlab/gitlabhq/refs/feature%2345/logs_tree')).to             route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature#45')
    expect(get('/gitlab/gitlabhq/refs/feature%2B45/logs_tree')).to             route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature+45')
    expect(get('/gitlab/gitlabhq/refs/feature@45/logs_tree')).to             route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature@45')
    expect(get('/gitlab/gitlabhq/refs/stable/logs_tree/foo/bar/baz')).to route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'stable', path: 'foo/bar/baz')
    expect(get('/gitlab/gitlabhq/refs/feature%2345/logs_tree/foo/bar/baz')).to route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature#45', path: 'foo/bar/baz')
    expect(get('/gitlab/gitlabhq/refs/feature%2B45/logs_tree/foo/bar/baz')).to route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature+45', path: 'foo/bar/baz')
    expect(get('/gitlab/gitlabhq/refs/feature@45/logs_tree/foo/bar/baz')).to route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'feature@45', path: 'foo/bar/baz')
    expect(get('/gitlab/gitlabhq/refs/stable/logs_tree/files.scss')).to route_to('projects/refs#logs_tree', project_id: 'gitlab/gitlabhq', id: 'stable', path: 'files.scss')
  end
end

#           diffs_project_merge_request GET    /:project_id/merge_requests/:id/diffs(.:format)           projects/merge_requests#diffs
#       automerge_project_merge_request POST   /:project_id/merge_requests/:id/automerge(.:format)       projects/merge_requests#automerge
# automerge_check_project_merge_request GET    /:project_id/merge_requests/:id/automerge_check(.:format) projects/merge_requests#automerge_check
#    branch_from_project_merge_requests GET    /:project_id/merge_requests/branch_from(.:format)         projects/merge_requests#branch_from
#      branch_to_project_merge_requests GET    /:project_id/merge_requests/branch_to(.:format)           projects/merge_requests#branch_to
#                project_merge_requests GET    /:project_id/merge_requests(.:format)                     projects/merge_requests#index
#                                       POST   /:project_id/merge_requests(.:format)                     projects/merge_requests#create
#             new_project_merge_request GET    /:project_id/merge_requests/new(.:format)                 projects/merge_requests#new
#            edit_project_merge_request GET    /:project_id/merge_requests/:id/edit(.:format)            projects/merge_requests#edit
#                 project_merge_request GET    /:project_id/merge_requests/:id(.:format)                 projects/merge_requests#show
#                                       PUT    /:project_id/merge_requests/:id(.:format)                 projects/merge_requests#update
#                                       DELETE /:project_id/merge_requests/:id(.:format)                 projects/merge_requests#destroy
describe Projects::MergeRequestsController, 'routing' do
  it 'to #diffs' do
    expect(get('/gitlab/gitlabhq/merge_requests/1/diffs')).to route_to('projects/merge_requests#diffs', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #automerge' do
    expect(post('/gitlab/gitlabhq/merge_requests/1/automerge')).to route_to(
      'projects/merge_requests#automerge',
      project_id: 'gitlab/gitlabhq', id: '1'
    )
  end

  it 'to #automerge_check' do
    expect(get('/gitlab/gitlabhq/merge_requests/1/automerge_check')).to route_to('projects/merge_requests#automerge_check', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #branch_from' do
    expect(get('/gitlab/gitlabhq/merge_requests/branch_from')).to route_to('projects/merge_requests#branch_from', project_id: 'gitlab/gitlabhq')
  end

  it 'to #branch_to' do
    expect(get('/gitlab/gitlabhq/merge_requests/branch_to')).to route_to('projects/merge_requests#branch_to', project_id: 'gitlab/gitlabhq')
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq/merge_requests/1.diff')).to route_to('projects/merge_requests#show', project_id: 'gitlab/gitlabhq', id: '1', format: 'diff')
    expect(get('/gitlab/gitlabhq/merge_requests/1.patch')).to route_to('projects/merge_requests#show', project_id: 'gitlab/gitlabhq', id: '1', format: 'patch')
  end

  it_behaves_like 'RESTful project resources' do
    let(:controller) { 'merge_requests' }
    let(:actions) { [:index, :create, :new, :edit, :show, :update] }
  end
end

#  raw_project_snippet GET    /:project_id/snippets/:id/raw(.:format)  snippets#raw
#     project_snippets GET    /:project_id/snippets(.:format)          snippets#index
#                      POST   /:project_id/snippets(.:format)          snippets#create
#  new_project_snippet GET    /:project_id/snippets/new(.:format)      snippets#new
# edit_project_snippet GET    /:project_id/snippets/:id/edit(.:format) snippets#edit
#      project_snippet GET    /:project_id/snippets/:id(.:format)      snippets#show
#                      PUT    /:project_id/snippets/:id(.:format)      snippets#update
#                      DELETE /:project_id/snippets/:id(.:format)      snippets#destroy
describe SnippetsController, 'routing' do
  it 'to #raw' do
    expect(get('/gitlab/gitlabhq/snippets/1/raw')).to route_to('projects/snippets#raw', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #index' do
    expect(get('/gitlab/gitlabhq/snippets')).to route_to('projects/snippets#index', project_id: 'gitlab/gitlabhq')
  end

  it 'to #create' do
    expect(post('/gitlab/gitlabhq/snippets')).to route_to('projects/snippets#create', project_id: 'gitlab/gitlabhq')
  end

  it 'to #new' do
    expect(get('/gitlab/gitlabhq/snippets/new')).to route_to('projects/snippets#new', project_id: 'gitlab/gitlabhq')
  end

  it 'to #edit' do
    expect(get('/gitlab/gitlabhq/snippets/1/edit')).to route_to('projects/snippets#edit', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq/snippets/1')).to route_to('projects/snippets#show', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #update' do
    expect(put('/gitlab/gitlabhq/snippets/1')).to route_to('projects/snippets#update', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it 'to #destroy' do
    expect(delete('/gitlab/gitlabhq/snippets/1')).to route_to('projects/snippets#destroy', project_id: 'gitlab/gitlabhq', id: '1')
  end
end

# test_project_hook GET    /:project_id/hooks/:id/test(.:format) hooks#test
#     project_hooks GET    /:project_id/hooks(.:format)          hooks#index
#                   POST   /:project_id/hooks(.:format)          hooks#create
#      project_hook DELETE /:project_id/hooks/:id(.:format)      hooks#destroy
describe Projects::HooksController, 'routing' do
  it 'to #test' do
    expect(get('/gitlab/gitlabhq/hooks/1/test')).to route_to('projects/hooks#test', project_id: 'gitlab/gitlabhq', id: '1')
  end

  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:index, :create, :destroy] }
    let(:controller) { 'hooks' }
  end
end

# project_commit GET    /:project_id/commit/:id(.:format) commit#show {id: /[[:alnum:]]{6,40}/, project_id: /[^\/]+/}
describe Projects::CommitController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/commit/4246fb')).to route_to('projects/commit#show', project_id: 'gitlab/gitlabhq', id: '4246fb')
    expect(get('/gitlab/gitlabhq/commit/4246fb.diff')).to route_to('projects/commit#show', project_id: 'gitlab/gitlabhq', id: '4246fb', format: 'diff')
    expect(get('/gitlab/gitlabhq/commit/4246fb.patch')).to route_to('projects/commit#show', project_id: 'gitlab/gitlabhq', id: '4246fb', format: 'patch')
    expect(get('/gitlab/gitlabhq/commit/4246fbd13872934f72a8fd0d6fb1317b47b59cb5')).to route_to('projects/commit#show', project_id: 'gitlab/gitlabhq', id: '4246fbd13872934f72a8fd0d6fb1317b47b59cb5')
  end
end

#    patch_project_commit GET    /:project_id/commits/:id/patch(.:format) commits#patch
#         project_commits GET    /:project_id/commits(.:format)           commits#index
#                         POST   /:project_id/commits(.:format)           commits#create
#          project_commit GET    /:project_id/commits/:id(.:format)       commits#show
describe Projects::CommitsController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:show] }
    let(:controller) { 'commits' }
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq/commits/master.atom')).to route_to('projects/commits#show', project_id: 'gitlab/gitlabhq', id: 'master', format: 'atom')
  end
end

#     project_team_members GET    /:project_id/team_members(.:format)          team_members#index
#                          POST   /:project_id/team_members(.:format)          team_members#create
#  new_project_team_member GET    /:project_id/team_members/new(.:format)      team_members#new
# edit_project_team_member GET    /:project_id/team_members/:id/edit(.:format) team_members#edit
#      project_team_member GET    /:project_id/team_members/:id(.:format)      team_members#show
#                          PUT    /:project_id/team_members/:id(.:format)      team_members#update
#                          DELETE /:project_id/team_members/:id(.:format)      team_members#destroy
describe Projects::TeamMembersController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:new, :create, :update, :destroy] }
    let(:controller) { 'team_members' }
  end
end

#     project_milestones GET    /:project_id/milestones(.:format)          milestones#index
#                        POST   /:project_id/milestones(.:format)          milestones#create
#  new_project_milestone GET    /:project_id/milestones/new(.:format)      milestones#new
# edit_project_milestone GET    /:project_id/milestones/:id/edit(.:format) milestones#edit
#      project_milestone GET    /:project_id/milestones/:id(.:format)      milestones#show
#                        PUT    /:project_id/milestones/:id(.:format)      milestones#update
#                        DELETE /:project_id/milestones/:id(.:format)      milestones#destroy
describe Projects::MilestonesController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:controller) { 'milestones' }
    let(:actions) { [:index, :create, :new, :edit, :show, :update] }
  end
end

# project_labels GET    /:project_id/labels(.:format) labels#index
describe Projects::LabelsController, 'routing' do
  it 'to #index' do
    expect(get('/gitlab/gitlabhq/labels')).to route_to('projects/labels#index', project_id: 'gitlab/gitlabhq')
  end
end

#        sort_project_issues POST   /:project_id/issues/sort(.:format)        issues#sort
# bulk_update_project_issues POST   /:project_id/issues/bulk_update(.:format) issues#bulk_update
#      search_project_issues GET    /:project_id/issues/search(.:format)      issues#search
#             project_issues GET    /:project_id/issues(.:format)             issues#index
#                            POST   /:project_id/issues(.:format)             issues#create
#          new_project_issue GET    /:project_id/issues/new(.:format)         issues#new
#         edit_project_issue GET    /:project_id/issues/:id/edit(.:format)    issues#edit
#              project_issue GET    /:project_id/issues/:id(.:format)         issues#show
#                            PUT    /:project_id/issues/:id(.:format)         issues#update
#                            DELETE /:project_id/issues/:id(.:format)         issues#destroy
describe Projects::IssuesController, 'routing' do
  it 'to #bulk_update' do
    expect(post('/gitlab/gitlabhq/issues/bulk_update')).to route_to('projects/issues#bulk_update', project_id: 'gitlab/gitlabhq')
  end

  it_behaves_like 'RESTful project resources' do
    let(:controller) { 'issues' }
    let(:actions) { [:index, :create, :new, :edit, :show, :update] }
  end
end

#         project_notes GET    /:project_id/notes(.:format)         notes#index
#                       POST   /:project_id/notes(.:format)         notes#create
#          project_note DELETE /:project_id/notes/:id(.:format)     notes#destroy
describe Projects::NotesController, 'routing' do
  it_behaves_like 'RESTful project resources' do
    let(:actions)    { [:index, :create, :destroy] }
    let(:controller) { 'notes' }
  end
end

# project_blame GET    /:project_id/blame/:id(.:format) blame#show {id: /.+/, project_id: /[^\/]+/}
describe Projects::BlameController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/blame/master/app/models/project.rb')).to route_to('projects/blame#show', project_id: 'gitlab/gitlabhq', id: 'master/app/models/project.rb')
    expect(get('/gitlab/gitlabhq/blame/master/files.scss')).to route_to('projects/blame#show', project_id: 'gitlab/gitlabhq', id: 'master/files.scss')
  end
end

# project_blob GET    /:project_id/blob/:id(.:format) blob#show {id: /.+/, project_id: /[^\/]+/}
describe Projects::BlobController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/blob/master/app/models/project.rb')).to route_to('projects/blob#show', project_id: 'gitlab/gitlabhq', id: 'master/app/models/project.rb')
    expect(get('/gitlab/gitlabhq/blob/master/app/models/compare.rb')).to route_to('projects/blob#show', project_id: 'gitlab/gitlabhq', id: 'master/app/models/compare.rb')
    expect(get('/gitlab/gitlabhq/blob/master/app/models/diff.js')).to route_to('projects/blob#show', project_id: 'gitlab/gitlabhq', id: 'master/app/models/diff.js')
    expect(get('/gitlab/gitlabhq/blob/master/files.scss')).to route_to('projects/blob#show', project_id: 'gitlab/gitlabhq', id: 'master/files.scss')
  end
end

# project_tree GET    /:project_id/tree/:id(.:format) tree#show {id: /.+/, project_id: /[^\/]+/}
describe Projects::TreeController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/tree/master/app/models/project.rb')).to route_to('projects/tree#show', project_id: 'gitlab/gitlabhq', id: 'master/app/models/project.rb')
    expect(get('/gitlab/gitlabhq/tree/master/files.scss')).to route_to('projects/tree#show', project_id: 'gitlab/gitlabhq', id: 'master/files.scss')
  end
end

describe Projects::BlobController, 'routing' do
  it 'to #edit' do
    expect(get('/gitlab/gitlabhq/edit/master/app/models/project.rb')).to(
      route_to('projects/blob#edit',
               project_id: 'gitlab/gitlabhq',
               id: 'master/app/models/project.rb'))
  end

  it 'to #preview' do
    expect(post('/gitlab/gitlabhq/preview/master/app/models/project.rb')).to(
      route_to('projects/blob#preview',
               project_id: 'gitlab/gitlabhq',
               id: 'master/app/models/project.rb'))
  end
end

# project_compare_index GET    /:project_id/compare(.:format)             compare#index {id: /[^\/]+/, project_id: /[^\/]+/}
#                       POST   /:project_id/compare(.:format)             compare#create {id: /[^\/]+/, project_id: /[^\/]+/}
#       project_compare        /:project_id/compare/:from...:to(.:format) compare#show {from: /.+/, to: /.+/, id: /[^\/]+/, project_id: /[^\/]+/}
describe Projects::CompareController, 'routing' do
  it 'to #index' do
    expect(get('/gitlab/gitlabhq/compare')).to route_to('projects/compare#index', project_id: 'gitlab/gitlabhq')
  end

  it 'to #compare' do
    expect(post('/gitlab/gitlabhq/compare')).to route_to('projects/compare#create', project_id: 'gitlab/gitlabhq')
  end

  it 'to #show' do
    expect(get('/gitlab/gitlabhq/compare/master...stable')).to     route_to('projects/compare#show', project_id: 'gitlab/gitlabhq', from: 'master', to: 'stable')
    expect(get('/gitlab/gitlabhq/compare/issue/1234...stable')).to route_to('projects/compare#show', project_id: 'gitlab/gitlabhq', from: 'issue/1234', to: 'stable')
  end
end

describe Projects::NetworkController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/network/master')).to route_to('projects/network#show', project_id: 'gitlab/gitlabhq', id: 'master')
    expect(get('/gitlab/gitlabhq/network/master.json')).to route_to('projects/network#show', project_id: 'gitlab/gitlabhq', id: 'master', format: 'json')
  end
end

describe Projects::GraphsController, 'routing' do
  it 'to #show' do
    expect(get('/gitlab/gitlabhq/graphs/master')).to route_to('projects/graphs#show', project_id: 'gitlab/gitlabhq', id: 'master')
  end
end

describe Projects::ForksController, 'routing' do
  it 'to #new' do
    expect(get('/gitlab/gitlabhq/fork/new')).to route_to('projects/forks#new', project_id: 'gitlab/gitlabhq')
  end

  it 'to #create' do
    expect(post('/gitlab/gitlabhq/fork')).to route_to('projects/forks#create', project_id: 'gitlab/gitlabhq')
  end
end

# project_avatar DELETE /project/avatar(.:format) projects/avatars#destroy
describe Projects::AvatarsController, 'routing' do
  it 'to #destroy' do
    expect(delete('/gitlab/gitlabhq/avatar')).to route_to(
      'projects/avatars#destroy', project_id: 'gitlab/gitlabhq')
  end
end
