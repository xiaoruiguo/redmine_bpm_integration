class BpmIntegration::TrackerProcessDefinition < BpmIntegrationBaseModel
  self.table_name = 'bpmint_tracker_proc_defs'

  belongs_to :tracker
  has_many :process_definitions

end
