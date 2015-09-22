class RenameTrackerProcessRelationsAndCreateProcessDefinitions < ActiveRecord::Migration
  def change
    rename_table :bpmint_tracker_process_relations, :bpmint_tracker_proc_defs
    add_column :bpmint_tracker_proc_defs, :current_version, :integer

    create_table :bpmint_process_definitions do |t|
      t.belongs_to :tracker_process_definition, index: {name: :idx_tracker_proc_def_on_process_definitions}
      t.column :process_identifier, :string, :null => false
      t.column :name, :string, :null => false
      t.column :key, :string, :null => false
      t.column :description, :string
      t.column :version, :integer, :null => false
    end

  end
end
