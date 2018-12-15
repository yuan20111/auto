class Projects::RepositoriesController < Projects::ApplicationController
  # Authorize
  before_filter :authorize_download_code!
  before_filter :require_non_empty_project, except: :create
  before_filter :authorize_admin_project!, only: :create

  def create
    @project.create_repository

    redirect_to @project
  end

  def archive
    unless can?(current_user, :download_code, @project)
      render_404 and return
    end

    file_path = ArchiveRepositoryService.new.execute(@project, params[:ref], params[:format])

    if file_path
      # Send file to user
      response.headers["Content-Length"] = File.open(file_path).size.to_s
      send_file file_path
    else
      render_404
    end
  end
end
