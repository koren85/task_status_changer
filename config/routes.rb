# config/routes.rb

RedmineApp::Application.routes.draw do
  # Ваши другие маршруты

  get 'settings/task_status_changer', to: 'task_status_changer_settings#show', as: 'settings_task_status_changer'
  post 'settings/task_status_changer', to: 'task_status_changer_settings#update'
  post 'task_status_changer/change_status', to: 'task_status_changer#change_status', as: 'change_status_task_status_changer'
end
