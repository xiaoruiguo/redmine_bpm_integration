
class BpmIntegration::ProcessDefinitionVersion < BpmIntegrationBaseModel
  self.table_name = 'bpmint_process_def_versions'

  belongs_to :process_definition, touch: true
  has_many :task_definitions
  has_many :form_fields, class_name: 'FormField', as: :form_able
  has_many :form_field_definitions, -> { order :name }, autosave: true, dependent: :destroy
  has_many :issue_process_instances, dependent: :destroy
  has_many :constants, autosave: true, dependent: :destroy, class_name: 'ProcessConstant'
  has_many :end_events, autosave: true, dependent: :destroy, class_name: 'ProcessEndEvent'

  accepts_nested_attributes_for :task_definitions
  accepts_nested_attributes_for :form_field_definitions
  accepts_nested_attributes_for :constants
  accepts_nested_attributes_for :end_events

  def end_event_for(end_event_identifier)
    end_events.includes(:issue_status).find_by(identifier: end_event_identifier)
  end

  def active= (is_active)
    if is_active == "1" || is_active == true
      av = process_definition.active_version
      if av && av != self
        av.active = false
        av.save
      end
    end
    super(is_active)
  end

end
