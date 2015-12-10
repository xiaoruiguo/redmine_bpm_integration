class BpmIntegration::IssueProcessInstance < BpmIntegrationBaseModel

  belongs_to :issue
  belongs_to :process_definition_version

end
