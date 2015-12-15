class BpmIntegration::TaskDefinition < BpmIntegrationBaseModel

  belongs_to :process_definition_version, touch: true
  belongs_to :issue_status
  belongs_to :watcher, class_name: :user, foreign_key: :watcher_id

  has_many :form_fields, class_name: 'FormField', as: :form_able

  scope :by_task_instance, -> (task_key, process_id) { joins(:process_definition_version)
                                                .where(key: task_key)
                                                .where(bpmint_process_def_versions: {process_identifier: process_id}) }

end
