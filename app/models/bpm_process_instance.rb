class BpmProcessInstance < ModelBase
  attr_accessor :id, :url, :businessKey, :suspended, :processDefinitionId, :taskDefinitionKey,
                :completed
end
