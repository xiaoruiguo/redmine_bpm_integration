class AddIndexToBpmintHumanTaskIssues < ActiveRecord::Migration
  def change
    add_index(:bpmint_human_task_issues, :human_task_id, name: 'bpmint_human_task_issues_human_task_id_idx')
  end
end
