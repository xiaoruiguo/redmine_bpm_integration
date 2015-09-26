class DropProcessInstance < ActiveRecord::Migration
  def change
    drop_table :bpmint_issue_process_instances
  end
end
