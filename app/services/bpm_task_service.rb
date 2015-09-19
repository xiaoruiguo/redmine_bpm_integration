class BpmTaskService < ActivitiBpmService

  require_relative '../models/bpm_task'

  def self.bpm_tasks
    hash_bpm_taks = get('/runtime/tasks', basic_auth: @@auth)
    tasks = []
    hash_bpm_taks["data"].each do |t|
      tasks << BpmTask.new(t)
    end
    return tasks
  end

  def self.complete_task(task_id, variables)
    post(
      '/runtime/tasks/' + task_id,
      basic_auth: @@auth,
      body: { action: "complete", variables: variables },
      headers: { 'Content-Type' => 'application/json' }
    )
  end

end
