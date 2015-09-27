class BpmProcessInstanceService < ActivitiBpmService

  def self.process_instance(process_instance_id)
    hash_bpm_processes = get(
      '/runtime/process-instances/' + process_instance_id,
      basic_auth: @@auth
    )
    BpmProcessInstance.new(hash_bpm_processes)
  end

  def self.process_instance_image(process_instance_id)
    get(
      '/runtime/process-instances/' + process_instance_id + '/diagram',
      basic_auth: @@auth
    ).body
  end

  def self.start_process(process_key, business_key, form)
    hash_process_instance = post(
      '/runtime/process-instances',
      basic_auth: @@auth,
      body: start_process_request_body(process_key, business_key, form),
      headers: { 'Content-Type' => 'application/json' }
    )
    BpmProcessInstance.new(hash_process_instance)
  end

  private

  def self.start_process_request_body(process_key, business_key, form)
    variables = []
    {
      processDefinitionKey: process_key,
      businessKey: business_key,
      variables: variables_from_hash(form)
    }.to_json
  end


end
