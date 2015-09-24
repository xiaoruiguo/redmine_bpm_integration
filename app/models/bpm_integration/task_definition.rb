class BpmIntegration::TaskDefinition < BpmIntegrationBaseModel

  belongs_to :process_definition
  has_many :form_fields, class_name: "BpmIntegration::FormField", as: :form_able

  scope :by_task_instance, -> (task_key, process_id) { joins(:process_definition)
                                                .where(key: task_key)
                                                .where(bpmint_process_definitions: {process_identifier: process_id}) }

end
