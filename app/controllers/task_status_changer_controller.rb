class TaskStatusChangerController < ApplicationController
  before_action :find_issue
  before_action :authorize_change_status, only: [:change_status]

  def change_status
    settings = Setting.plugin_task_status_changer['status_transition_rules'] || {}
    current_status_id = @issue.status_id.to_s
    rule = settings.values.find { |r| r['current_status'] == current_status_id }

    if rule
      assign_user_if_allowed(rule['assign_user_id'])
      update_custom_field_if_present(rule['custom_field_id'])

      if rule['new_status']
        @issue.init_journal(User.current)
        @issue.status_id = rule['new_status']
        @issue.save!
        flash[:notice] = 'Статус, исполнитель задачи и кастомное поле обновлены успешно.'
      else
        flash[:error] = 'Нет правила для изменения статуса.'
      end
    else
      flash[:error] = 'Не найдено подходящее правило.'
    end
    redirect_to issue_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  end

  def authorize_change_status
    settings = Setting.plugin_task_status_changer['status_transition_rules'] || {}
    rule = settings.values.find { |r| r['current_status'] == @issue.status_id.to_s }
    return flash[:error] = 'Не найдено подходящее правило.' unless rule && (user_allowed?(rule['check_user_id']) || group_allowed?(rule['check_user_id']))

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
        @issue.init_journal(User.current, "Счетчик возвратов обновлен с #{custom_value.value.to_i - 1} на #{custom_value.value.to_i}")
        @issue.save_custom_field_values
      end
    else
      flash[:error] = 'Выбранное кастомное поле недоступно в этой задаче.'
    end
  end

end
