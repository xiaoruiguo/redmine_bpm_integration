class CreateTaskDefinition < ActiveRecord::Migration
  def change
    create_table :bpmint_task_definitions do |t|
      t.column :key, :string, :null => false
      t.belongs_to :process_definition, index: true
    end

    change_table :bpmint_human_task_issues do |t|
      t.belongs_to :task_definition, index: true
    end

  end
end
