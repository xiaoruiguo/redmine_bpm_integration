class Httparty
  include HTTParty

  format :json
  base_uri Setting.plugin_bpm_integration[:bpms_url]

  def process_list
    hash_process_list = self.class.get('/repository/process-definitions')
    processes = []
    hash_process_list["data"].each do |p|
      processes << BpmProcess.new(p)
    end
    return processes
  end

  def start_process(process_id)
    self.class.post('/runtime/process-instances',
                body: start_process_request_body(process_id),
                headers: {'Content-Type' => 'application/json'})
  end

  def start_process_request_body(process_id, variables = [])
    process = { processId: process_id }
    process.to_json
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
