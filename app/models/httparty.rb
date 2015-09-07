class Httparty
  include HTTParty
  format :json
  base_uri Setting.plugin_bpm_integration[:bpms_url]

  def process_list
    processes = []
    self.class.get('/repository/process-definitions')["data"].each do |p|
      processes << BpmProcess.new( p )
    end
    return processes
  end

  def start_process(process_key)
    self.class.post(
      '/runtime/process-instances',
      body: { processDefinitionKey: process_key }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def bpm_tasks
    hash_bpm_taks = self.class.get('/runtime/tasks')
    tasks = []
    hash_bpm_taks["data"].each do |t|
      tasks << BpmTask.new(t)
    end
    return tasks
  end
end
