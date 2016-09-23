class BpmProcessInstance < ModelBase
  attr_accessor :id, :url, :businessKey, :suspended, :processDefinitionId, :taskDefinitionKey,
                :completed, :deleteReason, :startTime, :endTime, :endActivityId, :variables

  PROCESS_STATUS_VARIABLE_NAME = 'process_overall_status'

  def status_id_variable
    @status_id_variable ||= variables.detect do |v|
      v['name'] == BpmProcessInstance::PROCESS_STATUS_VARIABLE_NAME
    end.try(:[], 'value').try(:to_i)
  end

end
