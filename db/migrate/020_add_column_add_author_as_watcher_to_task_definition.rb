class AddColumnAddAuthorAsWatcherToTaskDefinition < ActiveRecord::Migration
  def change
    add_column :bpmint_task_definitions, :add_author_as_watcher, :boolean, null: true

    BpmIntegration::TaskDefinition.update_all(add_author_as_watcher: true)
  end
end
