class ActivitiBpmService
  include HTTMultiParty
  format :json

  base_uri Setting.plugin_bpm_integration[:bpms_url]

  require_relative '../models/bpm_task'

  @@auth = {
    username: Setting.plugin_bpm_integration[:bpms_user],
    password: Setting.plugin_bpm_integration[:bpms_pass]
  }

  def self.process_list
    processes = []
    process_list = get(
      '/repository/process-definitions',
      query: { latest: true },
      basic_auth: @@auth
    )["data"]

    process_list.each do |p|
      processes << BpmProcessDefinition.new(p)
    end

    return processes
  end

  def self.process_image(process_id)
    get(
      '/repository/process-definitions/' + process_id + '/image',
      basic_auth: @@auth
    ).body
  end

  def self.process_instance_image(process_instance_id)
    get(
      '/runtime/process-instances/' + process_instance_id + '/diagram',
      basic_auth: @@auth
    ).body
  end

  def self.start_process(process_key, form)
    post(
      '/runtime/process-instances',
      basic_auth: @@auth,
      body: start_process_request_body(process_key, form),
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.getFormData(processId)
    get(
      '/form/form-data',
      basic_auth: @@auth,
      query: { processDefinitionId: processId },
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.start_process_request_body(process_key, form)
    variables = []
    form.each { |k, v| variables << { name: k, value: v } }
    {
      processDefinitionId: process_key,
      variables: variables
    }.to_json
  end

  def self.deploy_process(process_data)
    post(
      '/repository/deployments',
      basic_auth: @@auth,
      multipart: true,
      query: {
        file: process_data
      }
    )
  end

  def self.bpm_tasks
    hash_bpm_taks = get('/runtime/tasks', basic_auth: @@auth)
    tasks = []
    hash_bpm_taks["data"].each do |t|
      tasks << BpmTask.new(t)
    end
    return tasks
  end
end
