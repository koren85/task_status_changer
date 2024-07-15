# app/models/status_transition_rule.rb

class StatusTransitionRule < ActiveRecord::Base
  validates :current_status, presence: true
  validates :new_status, presence: true

  belongs_to :current_status, class_name: 'IssueStatus', foreign_key: 'current_status'
  belongs_to :new_status, class_name: 'IssueStatus', foreign_key: 'new_status'
end
