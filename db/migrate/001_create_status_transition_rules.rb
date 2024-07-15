# /path/to/redmine/plugins/task_status_changer/db/migrate/001_create_status_transition_rules.rb

class CreateStatusTransitionRules < ActiveRecord::Migration[5.2]
  def change
    create_table :status_transition_rules do |t|
      t.integer :current_status, null: false
      t.integer :new_status, null: false
      t.timestamps
    end
  end
end
