class BaseService
  include Gitlab::CurrentSettings

  attr_accessor :project, :current_user, :params

  def initialize(project, user, params = {})
    @project, @current_user, @params = project, user, params.dup
  end

  def abilities
    Ability.abilities
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def notification_service
    NotificationService.new
  end

  def event_service
    EventCreateService.new
  end

  def log_info(message)
    Gitlab::AppLogger.info message
  end

  def system_hook_service
    SystemHooksService.new
  end

  def current_application_settings
    ApplicationSetting.current
  end

  private

  def error(message)
    {
      message: message,
      status: :error
    }
  end

  def success
    {
      status: :success
    }
  end
end
