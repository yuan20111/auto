# Controller for viewing a repository's file structure
class Projects::TreeController < Projects::ApplicationController
  include ExtractsPath

  before_filter :assign_ref_vars
  before_filter :authorize_download_code!
  before_filter :require_non_empty_project, except: [:new, :create]

  def show
    if tree.entries.empty?
      if @repository.blob_at(@commit.id, @path)
        redirect_to project_blob_path(@project, File.join(@ref, @path)) and return
      else
        return not_found!
      end
    end

    respond_to do |format|
      format.html
      # Disable cache so browser history works
      format.js { no_cache_headers }
    end
  end
end
