class AddDefaultStatusAndNameToTaskDefinitions < ActiveRecord::Migration
  def change
    add_belongs_to :bpmint_task_definitions, :issue_status, null: true
  end
end
