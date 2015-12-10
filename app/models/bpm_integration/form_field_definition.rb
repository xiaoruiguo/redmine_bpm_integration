class BpmIntegration::FormFieldDefinition < BpmIntegrationBaseModel

  belongs_to :custom_field
  belongs_to :process_definition_version

  scope :process_field, ->(process_id, field_id){ joins(:process_definition)
                              .where(field_id: field_id)
                              .where(bpmint_process_def_versions: {process_identifier: process_id}) }

end
