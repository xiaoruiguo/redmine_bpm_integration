class CreateFormFields < ActiveRecord::Migration
  def change
    create_table :bpmint_form_fields do |t|
      t.belongs_to :process_definition, index: {name: :idx_form_fields_on_process_definitions}
      t.column :field_id, :string, :null => false
      t.column :name, :string, :null => false
      t.column :field_type, :string, :null => false
      t.column :readable, :boolean
      t.column :writable, :boolean
      t.column :required, :boolean
      t.column :date_pattern, :string
      t.belongs_to :custom_field
      t.column :type, :string
    end
  end
end
