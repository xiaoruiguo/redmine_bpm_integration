class CreateProcessConstants < ActiveRecord::Migration
  def change
    create_table :bpmint_process_constants do |t|
      t.column :name, :string, null: false
      t.column :constant_type, :string
      t.column :value, :string
      t.belongs_to :process_definition, index: true, null: false
    end
  end
end
