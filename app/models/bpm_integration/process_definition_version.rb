
class BpmIntegration::ProcessDefinitionVersion < BpmIntegrationBaseModel
  self.table_name = 'bpmint_process_def_versions'

  belongs_to :process_definition
  has_many :task_definitions
  has_many :form_fields, class_name: 'FormField', as: :form_able
  has_many :form_field_definitions, autosave: true, dependent: :destroy
  has_many :issue_process_instances
  has_many :constants, autosave: true, dependent: :destroy, class_name: 'ProcessConstant'
  has_many :end_events, autosave: true, dependent: :destroy, class_name: 'ProcessEndEvent'

end
