class CreateTrackerProcessRelation < ActiveRecord::Migration
  def change
    create_table :bpmint_tracker_process_relations, :force => true do |t|
      t.references :tracker, index: true, :null => false
      t.column :process_definition_key, :string, :null => false
    end

    add_foreign_key :bpmint_tracker_process_relations, :trackers
  end
end
