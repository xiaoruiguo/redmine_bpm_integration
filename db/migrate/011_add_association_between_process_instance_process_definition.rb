class AddAssociationBetweenProcessInstanceProcessDefinition < ActiveRecord::Migration
  def change
    change_table  :bpmint_issue_process_instances do |t|
    	t.belongs_to :process_definition, index: true 
    end
    add_foreign_key :bpmint_issue_process_instances, :bpmint_process_definitions, column: :process_definition_id
  end
end