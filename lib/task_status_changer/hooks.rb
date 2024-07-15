# /path/to/redmine/plugins/task_status_changer/lib/task_status_changer/hooks.rb
module TaskStatusChanger
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_details_bottom, partial: 'task_status_changer/change_status_button'
    render_on :view_layouts_base_html_head, partial: 'task_status_changer/add_custom_button_js'
  end
end
