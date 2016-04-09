class AddTrackerToTaskDefinition < ActiveRecord::Migration
  def change
    add_belongs_to :bpmint_task_definitions, :tracker, null: true
  end
end
