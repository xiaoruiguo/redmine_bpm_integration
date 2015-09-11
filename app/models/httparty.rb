class Httparty
  include HTTMultiParty
  format :json
  base_uri Setting.plugin_bpm_integration[:bpms_url]

  @@auth = {
    username: Setting.plugin_bpm_integration[:bpms_user],
    password: Setting.plugin_bpm_integration[:bpms_pass]
  }

  def process_list
    processes = []
    self.class.get('/repository/process-definitions', basic_auth: @@auth)["data"].each do |p|
      processes << BpmProcess.new( p )
    end
    return processes
  end

  def start_process(process_key, form)
    self.class.post(
      '/runtime/process-instances',
      basic_auth: @@auth,
      body: start_process_request_body(process_key, form),
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def getFormData(processId)
    self.class.get(
      '/form/form-data',
      basic_auth: @@auth,
      query: { processDefinitionId: processId },
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def start_process_request_body(process_key, form)
    variables = []
    form.each { |k, v| variables << { name: k, value: v } }
    {
      processDefinitionId: process_key,
      variables: variables
    }.to_json
  end

  def deploy_process(processData)
    self.class.post(
      '/repository/deployments',
      basic_auth: @@auth,
      query: {
        file: processData
      }
    )
  end

  def bpm_tasks
    hash_bpm_taks = self.class.get('/runtime/tasks', basic_auth: @@auth)
    tasks = []
    hash_bpm_taks["data"].each do |t|
      tasks << BpmTask.new(t)
    end
    return tasks
  end
end
