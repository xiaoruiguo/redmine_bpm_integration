class AddWatcherColumnToTaskDefinitions < ActiveRecord::Migration

  def change

    add_column :bpmint_task_definitions, :watcher_id, :integer
    add_foreign_key :bpmint_task_definitions, :users, column: :watcher_id, primary_key: :id

  end

end
