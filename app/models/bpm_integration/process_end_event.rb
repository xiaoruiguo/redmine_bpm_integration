class BpmIntegration::ProcessEndEvent < BpmIntegrationBaseModel

  belongs_to :process_definition_version , touch: true
  belongs_to :issue_status

end
