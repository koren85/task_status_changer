# /path/to/redmine/plugins/task_status_changer/app/controllers/task_status_changer_controller.rb

class TaskStatusChangerController < ApplicationController
  before_action :find_issue, only: [:change_status]

  before_action :authorize_change_status, only: [:change_status]

  def change_status
    settings = Setting.plugin_task_status_changer['status_transition_rules'] || {}
    current_status_id = @issue.status_id.to_s
    rule = settings.values.find { |r| r['current_status'] == current_status_id }

    if rule
      assign_user_if_allowed(rule['assign_user_id'])

      custom_field_options = params[:custom_field_options] || []

      # Всегда обновляем общий счётчик, даже если конкретные поля не выбраны
      update_custom_field_if_present(rule['general_counter']) if rule['general_counter'].present?

      custom_field_options.each do |field_key|
        # Получаем ID кастомного поля из настроек
        custom_field_id = rule[field_key]
        update_custom_field_if_present(custom_field_id) if custom_field_id.present?
      end

      if rule['new_status']
        @issue.init_journal(User.current)
        @issue.status_id = rule['new_status']
        @issue.save!
        render json: { success: true, message: 'Статус и кастомные поля обновлены успешно.' }
      else
        render json: { success: false, message: 'Нет правила для изменения статуса.' }
      end
    else
      render json: { success: false, message: 'Не найдено подходящее правило.' }
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  # def authorize_change_status
  #   settings = Setting.plugin_task_status_changer['status_transition_rules'] || {}
  #   rule = settings.values.find { |r| r['current_status'] == @issue.status_id.to_s }
  #   return head :forbidden unless rule && (user_allowed?(rule['check_user_id']) || group_allowed?(rule['check_user_id']))
  #
  #   true
  # end

  def authorize_change_status
    settings = Setting.plugin_task_status_changer['status_transition_rules'] || {}
    rule = settings.values.find { |r| r['current_status'] == @issue.status_id.to_s } # Используем @issue

    return flash[:error] = 'Не найдено подходящее правило.' unless User.current.admin? || rule && (user_allowed?(rule['check_user_id']) || group_allowed?(rule['check_user_id']))
   
    Rails.logger.info("Пользователь #{User.current.login} имеет права для изменения статуса задачи ##{@issue.id}.")
    true
  end




  def user_allowed?(user_id)
    User.current.id.to_s == user_id.to_s
  end

  def group_allowed?(user_id)
    group = Group.find_by_id(user_id)
    group && User.current.groups.include?(group)
  end

  def assign_user_if_allowed(user_id)
    assigned_to = Principal.find_by_id(user_id)
    if assigned_to && (assigned_to.is_a?(User) && assigned_to.active?) || assigned_to.is_a?(Group)
      @issue.assigned_to = assigned_to
    else
      flash[:error] = 'Назначенный пользователь или группа не доступны.'
    end
  end

  def update_custom_field_if_present(custom_field_id)
    custom_field = CustomField.find_by_id(custom_field_id)
    if custom_field && @issue.available_custom_fields.include?(custom_field)
      custom_value = @issue.custom_field_values.detect { |cfv| cfv.custom_field_id == custom_field.id }
      if custom_value
        new_value = custom_value.value.to_i + 1
        custom_value.value = new_value
        @issue.init_journal(User.current, "Обновлено кастомное поле #{custom_field.name} с #{custom_value.value.to_i - 1} на #{custom_value.value.to_i}")
        @issue.save_custom_field_values
      end
    else
      Rails.logger.error("Кастомное поле недоступно в задаче: #{custom_field_id}")
      flash[:error] = 'Выбранное кастомное поле недоступно в этой задаче.'
    end
  end
end
