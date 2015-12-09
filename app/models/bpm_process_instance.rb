class BpmProcessInstance < ModelBase
  attr_accessor :id, :url, :businessKey, :suspended, :processDefinitionId, :taskDefinitionKey,
                :completed, :deleteReason, :startTime, :endTime, :endActivityId
end
