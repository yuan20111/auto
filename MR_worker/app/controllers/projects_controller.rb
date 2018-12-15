class ProjectsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  before_filter :project, except: [:new, :create]
  before_filter :repository, except: [:new, :create]

  # Authorize
  before_filter :authorize_admin_project!, only: [:edit, :update, :destroy, :transfer, :archive, :unarchive, :toggle_pam_enabled, :toggle_am_enabled]
  before_filter :set_title, only: [:new, :create]
  before_filter :event_filter, only: :show

  layout 'navless', only: [:new, :create, :fork]

  def new
    @project = Project.new
  end

  def edit
    render 'edit', layout: 'project_settings'
  end

  def create
    @project = ::Projects::CreateService.new(current_user, project_params).execute

    @project.am_enabled = Project.all.last.am_enabled
    @project.save

    if @project.saved?
      redirect_to project_path(@project), notice: 'Project was successfully created.'
    else
      render 'new'
    end
  end

  def update
    status = ::Projects::UpdateService.new(@project, current_user, project_params).execute

    respond_to do |format|
      if status
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to edit_project_path(@project), notice: 'Project was successfully updated.' }
        format.js
      else
        format.html { render 'edit', layout: 'project_settings' }
        format.js
      end
    end
  end

  def transfer
    ::Projects::TransferService.new(project, current_user, project_params).execute
    if @project.errors[:namespace_id].present?
      flash[:alert] = @project.errors[:namespace_id].first
    end
  end

  def show
    if @project.import_in_progress?
      redirect_to project_import_path(@project)
      return
    end

    limit = (params[:limit] || 20).to_i

    @show_star = !(current_user && current_user.starred?(@project))

    respond_to do |format|
      format.html do
        if @project.repository_exists?
          if @project.empty_repo?
            render 'projects/empty', layout: user_layout
          else
            @last_push = current_user.recent_push(@project.id) if current_user
            render :show, layout: user_layout
          end
        else
          render 'projects/no_repo', layout: user_layout
        end
      end

      format.json do
        @events = @project.events.recent
        @events = event_filter.apply_filter(@events).with_associations
        @events = @events.limit(limit).offset(params[:offset] || 0)
        pager_json('events/_events', @events.count)
      end
    end
  end

  def destroy
    return access_denied! unless can?(current_user, :remove_project, @project)

    ::Projects::DestroyService.new(@project, current_user, {}).execute

    respond_to do |format|
      format.html do
        flash[:alert] = 'Project deleted.'

        if request.referer.include?('/admin')
          redirect_to admin_projects_path
        else
          redirect_to projects_dashboard_path
        end
      end
    end
  end

  def autocomplete_sources
    note_type = params['type']
    note_id = params['type_id']
    autocomplete = ::Projects::AutocompleteService.new(@project)
    participants = ::Projects::ParticipantsService.new(@project, current_user).execute(note_type, note_id)

    @suggestions = {
      emojis: autocomplete_emojis,
      issues: autocomplete.issues,
      mergerequests: autocomplete.merge_requests,
      members: participants
    }

    respond_to do |format|
      format.json { render json: @suggestions }
    end
  end

  def archive
    return access_denied! unless can?(current_user, :archive_project, @project)
    @project.archive!

    respond_to do |format|
      format.html { redirect_to @project }
    end
  end

  def unarchive
    return access_denied! unless can?(current_user, :archive_project, @project)
    @project.unarchive!

    respond_to do |format|
      format.html { redirect_to @project }
    end
  end

  def upload_image
    link_to_image = ::Projects::ImageService.new(repository, params, root_url).execute

    respond_to do |format|
      if link_to_image
        format.json { render json: { link: link_to_image } }
      else
        format.json { render json: 'Invalid file.', status: :unprocessable_entity }
      end
    end
  end

  def toggle_star
    current_user.toggle_star(@project)
    @project.reload
    render json: { star_count: @project.star_count }
  end

  def toggle_pam_enabled
    @project.pam_enabled = !@project.pam_enabled
    respond_to do |format|
      if @project.save
        format.json { render :json => @project }
        format.js { render 'toggle_pam_enabled.js.erb', locals: { project: @project } }
      else
        #
      end
    end
  end

  def toggle_am_enabled
    Project.update_all(:am_enabled => !@project.am_enabled)
    @projects = Project.all
    @project = @projects.last
    respond_to do |format|
      format.html
      format.js { render 'toggle_am_enabled.js.erb', locals: { project: @project } }
    end
  end

  def markdown_preview
    render text: view_context.markdown(params[:md_text])
  end

  private

  def upload_path
    base_dir = FileUploader.generate_dir
    File.join(repository.path_with_namespace, base_dir)
  end

  def accepted_images
    %w(png jpg jpeg gif)
  end

  def set_title
    @title = 'New Project'
  end

  def user_layout
    current_user ? 'projects' : 'public_projects'
  end

  def project_params
    params.require(:project).permit(
      :name, :path, :description, :issues_tracker, :tag_list,
      :issues_enabled, :merge_requests_enabled, :snippets_enabled, :issues_tracker_id, :default_branch,
      :wiki_enabled, :visibility_level, :import_url, :last_activity_at, :namespace_id, :avatar, :pam_enabled
    )
  end

  def autocomplete_emojis
    Rails.cache.fetch("autocomplete-emoji-#{Emoji::VERSION}") do
      Emoji.names.map do |e|
        {
          name: e,
          path: view_context.image_url("emoji/#{e}.png")
        }
      end
    end
  end
end
