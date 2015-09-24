class BpmIntegration::ProcessFormField < BpmIntegration::FormField

  belongs_to :process_definition
  belongs_to :custom_field, class_name: 'IssueCustomField'

end
