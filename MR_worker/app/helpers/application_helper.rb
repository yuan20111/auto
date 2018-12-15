require 'digest/md5'
require 'uri'

module ApplicationHelper
  COLOR_SCHEMES = {
    1 => 'white',
    2 => 'dark',
    3 => 'solarized-light',
    4 => 'solarized-dark',
    5 => 'monokai',
  }
  COLOR_SCHEMES.default = 'white'

  # Helper method to access the COLOR_SCHEMES
  #
  # The keys are the `color_scheme_ids`
  # The values are the `name` of the scheme.
  #
  # The preview images are `name-scheme-preview.png`
  # The stylesheets should use the css class `.name`
  def color_schemes
    COLOR_SCHEMES.freeze
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check
  #
  # Examples
  #
  #   # On TreeController
  #   current_controller?(:tree)           # => true
  #   current_controller?(:commits)        # => false
  #   current_controller?(:commits, :tree) # => true
  def current_controller?(*args)
    args.any? { |v| v.to_s.downcase == controller.controller_name }
  end

  # Check if a particular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Projects#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| v.to_s.downcase == action_name }
  end

  def project_icon(project_id, options = {})
    project =
      if project_id.is_a?(Project)
        project = project_id
      else
        Project.find_with_namespace(project_id)
      end

    if project.avatar.present?
      image_tag project.avatar.url, options
    elsif project.avatar_in_git
      image_tag project_avatar_path(project), options
    else # generated icon
      project_identicon(project, options)
    end
  end

  def project_identicon(project, options = {})
    allowed_colors = {
      red: 'FFEBEE',
      purple: 'F3E5F5',
      indigo: 'E8EAF6',
      blue: 'E3F2FD',
      teal: 'E0F2F1',
      orange: 'FBE9E7',
      gray: 'EEEEEE'
    }

    options[:class] ||= ''
    options[:class] << ' identicon'
    bg_key = project.id % 7
    style = "background-color: ##{ allowed_colors.values[bg_key] }; color: #555"

    content_tag(:div, class: options[:class], style: style) do
      project.name[0, 1].upcase
    end
  end

  def group_icon(group_path)
    group = Group.find_by(path: group_path)
    if group && group.avatar.present?
      group.avatar.url
    else
      image_path('no_group_avatar.png')
    end
  end

  def avatar_icon(user_email = '', size = nil)
    user = User.find_by(email: user_email)

    if user
      user.avatar_url(size) || default_avatar
    else
      gravatar_icon(user_email, size)
    end
  end

  def gravatar_icon(user_email = '', size = nil)
    GravatarService.new.execute(user_email, size) ||
      default_avatar
  end

  def default_avatar
    image_path('no_avatar.png')
  end

  def last_commit(project)
    if project.repo_exists?
      time_ago_with_tooltip(project.repository.commit.committed_date)
    else
      'Never'
    end
  rescue
    'Never'
  end

  def grouped_options_refs
    repository = @project.repository

    options = [
      ['Branches', repository.branch_names],
      ['Tags', VersionSorter.rsort(repository.tag_names)]
    ]

    # If reference is commit id - we should add it to branch/tag selectbox
    if(@ref && !options.flatten.include?(@ref) &&
       @ref =~ /^[0-9a-zA-Z]{6,52}$/)
      options << ['Commit', [@ref]]
    end

    grouped_options_for_select(options, @ref || @project.default_branch)
  end

  def emoji_autocomplete_source
    # should be an array of strings
    # so to_s can be called, because it is sufficient and to_json is too slow
    Emoji.names.to_s
  end

  def app_theme
    Gitlab::Theme.css_class_by_id(current_user.try(:theme_id))
  end

  def theme_type
    Gitlab::Theme.type_css_class_by_id(current_user.try(:theme_id))
  end

  def user_color_scheme_class
    COLOR_SCHEMES[current_user.try(:color_scheme_id)] if defined?(current_user)
  end

  # Define whenever show last push event
  # with suggestion to create MR
  def show_last_push_widget?(event)
    # Skip if event is not about added or modified non-master branch
    return false unless event && event.last_push_to_non_root? && !event.rm_ref?

    project = event.project

    # Skip if project repo is empty or MR disabled
    return false unless project && !project.empty_repo? && project.merge_requests_enabled

    # Skip if user already created appropriate MR
    return false if project.merge_requests.where(source_branch: event.branch_name).opened.any?

    # Skip if user removed branch right after that
    return false unless project.repository.branch_names.include?(event.branch_name)

    true
  end

  def hexdigest(string)
    Digest::SHA1.hexdigest string
  end

  def authbutton(provider, size = 64)
    file_name = "#{provider.to_s.split('_').first}_#{size}.png"
    image_tag(image_path("authbuttons/#{file_name}"), alt: "Sign in with #{provider.to_s.titleize}")
  end

  def simple_sanitize(str)
    sanitize(str, tags: %w(a span))
  end


  def body_data_page
    path = controller.controller_path.split('/')
    namespace = path.first if path.second

    [namespace, controller.controller_name, controller.action_name].compact.join(':')
  end

  # shortcut for gitlab config
  def gitlab_config
    Gitlab.config.gitlab
  end

  # shortcut for gitlab extra config
  def extra_config
    Gitlab.config.extra
  end

  def search_placeholder
    if @project && @project.persisted?
      'Search in this project'
    elsif @snippet || @snippets || @show_snippets
      'Search snippets'
    elsif @group && @group.persisted?
      'Search in this group'
    else
      'Search'
    end
  end

  def broadcast_message
    BroadcastMessage.current
  end

  def time_ago_with_tooltip(date, placement = 'top', html_class = 'time_ago')
    capture_haml do
      haml_tag :time, date.to_s,
        class: html_class, datetime: date.getutc.iso8601, title: date.stamp('Aug 21, 2011 9:23pm'),
        data: { toggle: 'tooltip', placement: placement }

      haml_tag :script, "$('." + html_class + "').timeago().tooltip()"
    end.html_safe
  end

  def render_markup(file_name, file_content)
    GitHub::Markup.render(file_name, file_content).
      force_encoding(file_content.encoding).html_safe
  rescue RuntimeError
    simple_format(file_content)
  end

  def markup?(filename)
    Gitlab::MarkdownHelper.markup?(filename)
  end

  def gitlab_markdown?(filename)
    Gitlab::MarkdownHelper.gitlab_markdown?(filename)
  end

  def link_to(name = nil, options = nil, html_options = nil, &block)
    begin
      uri = URI(options)
      host = uri.host
      absolute_uri = uri.absolute?
    rescue URI::InvalidURIError, ArgumentError
      host = nil
      absolute_uri = nil
    end

    # Add 'nofollow' only to external links
    if host && host != Gitlab.config.gitlab.host && absolute_uri
      if html_options
        if html_options[:rel]
          html_options[:rel] << ' nofollow'
        else
          html_options.merge!(rel: 'nofollow')
        end
      else
        html_options = Hash.new
        html_options[:rel] = 'nofollow'
      end
    end

    super
  end

  def escaped_autolink(text)
    auto_link ERB::Util.html_escape(text), link: :urls
  end

  def promo_host
    'about.gitlab.com'
  end

  def promo_url
    'https://' + promo_host
  end

  def page_filter_path(options={})
    exist_opts = {
      state: params[:state],
      scope: params[:scope],
      label_name: params[:label_name],
      milestone_id: params[:milestone_id],
      assignee_id: params[:assignee_id],
      author_id: params[:author_id],
      sort: params[:sort],
    }

    options = exist_opts.merge(options)

    path = request.path
    path << "?#{options.to_param}"
    path
  end

  def outdated_browser?
    browser.ie? && browser.version.to_i < 10
  end

  def path_to_key(key, admin = false)
    if admin
      admin_user_key_path(@user, key)
    else
      profile_key_path(key)
    end
  end

  def nav_sidebar_class
    if nav_menu_collapsed?
      "page-sidebar-collapsed"
    else
      "page-sidebar-expanded"
    end
  end
end
