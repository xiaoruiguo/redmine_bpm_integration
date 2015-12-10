class BpmIntegration::ProcessDefinition < BpmIntegrationBaseModel

  has_one :tracker_process_definition
  has_one :tracker, through: :tracker_process_definition
  has_many :versions, class_name: 'ProcessDefinitionVersion'

  has_one :active_version, ->() { where(bpmint_process_def_versions: { active: true }) },
                          class_name: 'ProcessDefinitionVersion'

  validates :key, uniqueness: true
end
