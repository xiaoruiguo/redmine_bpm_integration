class BpmIntegration::FormFieldDefinition < BpmIntegrationBaseModel

  belongs_to :custom_field
  belongs_to :process_definition

  scope :process_field, ->(process_id, field_id){ joins(:process_definition)
                              .where(field_id: field_id)
                              .where(bpmint_process_definitions: {process_identifier: process_id}) }

end
