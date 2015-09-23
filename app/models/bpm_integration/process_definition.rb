
class BpmIntegration::ProcessDefinition < BpmIntegrationBaseModel

  belongs_to :tracker_process_definition

  scope :latest, -> {joins('join ' +
                            '(select pd.key as p_key, max(pd.version) as max_version ' +
                              'from bpmint_process_definitions pd group by pd.key) as tmp ' +
                               'on bpmint_process_definitions.key = tmp.p_key ' +
                               'and bpmint_process_definitions.version = tmp.max_version')}

end
