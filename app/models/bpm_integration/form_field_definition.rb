class BpmIntegration::FormFieldDefinition < BpmIntegrationBaseModel

  belongs_to :custom_field
  belongs_to :process_definition_version, touch: true

end
