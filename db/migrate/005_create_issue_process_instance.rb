class CreateIssueProcessInstance < ActiveRecord::Migration
  def change
    create_table :bpmint_issue_process_instances do |t|
      t.belongs_to :issue, index: true
      t.column :process_instance_id, :integer
    end
  end
end
