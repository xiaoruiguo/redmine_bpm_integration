class CreateProcessEndEvents < ActiveRecord::Migration
  def change
    create_table :bpmint_process_end_events do |t|
      t.column :identifier, :string, null: false
      t.column :name, :string, null: false
      t.belongs_to :issue_status, index: true, null: true
      t.belongs_to :process_definition, index: true, null: false
    end
  end
end
