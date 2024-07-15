class TaskStatusChanger::SettingsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  def show
    @settings = Setting.plugin_task_status_changer
  end

  def update
    Setting.plugin_task_status_changer = params[:settings]
    redirect_to settings_redmine_task_status_changer_path, notice: l(:notice_successful_update)
  end
end
