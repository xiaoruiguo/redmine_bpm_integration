class CreateProcessDefinitionVersionAndRefactorDatabaseModel < ActiveRecord::Migration
  def change

    rename_table(:bpmint_process_definitions, :bpmint_process_def_versions)
    remove_column(:bpmint_process_def_versions, :key, :string)
    change_table :bpmint_process_def_versions do |t|
      t.column(:active, :boolean)
      t.rename_index('idx_tracker_proc_def_on_process_definitions',
                  'idx_process_definitions_on_process_definition_id')
      t.rename(:tracker_process_definition_id, :process_definition_id)
    end

    rename_table(:bpmint_tracker_proc_defs, :bpmint_process_definitions)
    remove_column(:bpmint_process_definitions, :current_version, :integer)
    reversible do |direction|
      direction.up    { remove_foreign_key :bpmint_process_definitions, :trackers }
      direction.down  { add_foreign_key :bpmint_process_definitions, :trackers }
    end
    change_table :bpmint_process_definitions do |t|
      t.remove_belongs_to :tracker
      t.rename(:process_definition_key, :key)
      t.string(:name)
    end

    create_table :bpmint_tracker_proc_defs do |t|
      t.belongs_to :tracker
      t.belongs_to :process_definition
    end

    change_table :bpmint_form_field_definitions do |t|
      t.rename_index('index_bpmint_form_field_definitions_on_process_definition_id',
                  'index_bpmint_form_field_definitions_on_proc_def_version_id')
      t.rename(:process_definition_id, :process_definition_version_id)
    end

    change_table :bpmint_process_constants do |t|
      t.rename(:process_definition_id, :process_definition_version_id)
    end

    change_table :bpmint_task_definitions do |t|
      t.rename(:process_definition_id, :process_definition_version_id)
    end

    change_table :bpmint_issue_process_instances do |t|
      t.rename_index('index_bpmint_issue_process_instances_on_process_definition_id',
                  'index_bpmint_issue_process_instances_on_proc_def_version_id')
      t.rename(:process_definition_id, :process_definition_version_id)
    end

    change_table :bpmint_process_end_events do |t|
      t.rename(:process_definition_id, :process_definition_version_id)
    end

  end
end
