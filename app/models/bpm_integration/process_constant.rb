class BpmIntegration::ProcessConstant < BpmIntegrationBaseModel

  belongs_to :process_definition_version, touch: true

end
