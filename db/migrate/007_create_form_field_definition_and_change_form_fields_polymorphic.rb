class CreateFormFieldDefinitionAndChangeFormFieldsPolymorphic < ActiveRecord::Migration
  def change
    create_table :bpmint_form_field_definitions do |t|
      t.belongs_to :process_definition, index: true
      t.belongs_to :custom_field, index: true
      t.column :field_id, :string, :null => false
      t.column :name, :string
      t.column :field_type, :string
    end

    remove_column :bpmint_form_fields, :field_id, :integer
    remove_column :bpmint_form_fields, :process_definition_id, :integer
    remove_column :bpmint_form_fields, :type, :string
    remove_column :bpmint_form_fields, :custom_field_id, :integer
    remove_column :bpmint_form_fields, :name, :integer
    remove_column :bpmint_form_fields, :field_type, :string

    change_table :bpmint_form_fields do |t|
      t.column :form_able_id, :integer
      t.column :form_able_type, :string
      t.belongs_to :form_field_definition, index: true
    end

    add_index :bpmint_form_fields, :form_able_id
  end
end
