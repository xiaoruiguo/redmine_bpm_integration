class AddColumnProcessCompleted < ActiveRecord::Migration
  def change
    add_column :bpmint_issue_process_instances, :completed, :boolean, default: true
  end
end
