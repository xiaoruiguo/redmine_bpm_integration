class CreateHumanTaskIssueRelation < ActiveRecord::Migration
  def change
    create_table :bpmint_human_task_issues, :force => true do |t|
      t.references :issue, index: true, :null => false
      t.column :human_task_id, :string, :null => false
    end

    add_foreign_key :bpmint_human_task_issues, :issues
  end
end
