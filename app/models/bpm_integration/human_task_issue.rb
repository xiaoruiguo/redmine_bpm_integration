class BpmIntegration::HumanTaskIssue < BpmIntegrationBaseModel

  belongs_to :task_definition
  has_many :form_fields, through: :task_definition

end
