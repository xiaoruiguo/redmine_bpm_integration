class ChangeProcessDefinitionDescriptionFromStringToText < ActiveRecord::Migration

  def up
    change_column :bpmint_process_def_versions, :description, :text
  end

  def down
    change_column :bpmint_process_def_versions, :description, :string
  end

end
