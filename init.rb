
Redmine::Plugin.register :task_status_changer do
  name 'Task Status Changer plugin'
  author 'Chernyaev A.A.'
  description 'This plugin adds a button to change task status based on predefined rules'
  version '0.0.1'
  settings default: {'status_transition_rules' => []}, partial: 'task_status_changer/settings'
  permission :change_status, {:task_status_changer => [:change_status]}, :require => :loggedin
end

require_dependency 'task_status_changer/hooks'
