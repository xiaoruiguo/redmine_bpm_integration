class AddColumnProcessEndEventNotes < ActiveRecord::Migration
  def change
    add_column :bpmint_process_end_events, :notes, :string
  end
end
