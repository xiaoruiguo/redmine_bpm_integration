class BpmIntegration::ProcessEndEvent < BpmIntegrationBaseModel

  belongs_to :process_definition
  belongs_to :issue_status

end
