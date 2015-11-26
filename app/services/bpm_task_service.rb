class BpmTaskService < ActivitiBpmService

  require_relative '../models/bpm_task'

  def self.task_list(process_instance_id = nil)
    if process_instance_id
      hash_bpm_tasks = get("/runtime/tasks?processInstanceId=#{process_instance_id}", basic_auth: @@auth)
    else
      hash_bpm_tasks = get("/runtime/tasks", basic_auth: @@auth)
    end
    tasks = []
    hash_bpm_tasks["data"].each do |t|
      tasks << BpmTask.new(t)
    end
    return tasks
  end

  def self.resolve_task(task_id, variables)
    post(
      '/runtime/tasks/' + task_id,
      basic_auth: @@auth,
      body: resolve_task_request_body(variables),
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.task_definitions(processId)
    get(
      "/repository/task-definitions/#{processId}",
      basic_auth: @@auth,
      headers: { 'Content-Type' => 'application/json' }
    )['data']
  end

  def self.form_data(taskId)
    get(
      '/form/form-data',
      basic_auth: @@auth,
      query: { taskId: taskId },
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  private

  def self.resolve_task_request_body(form)
    {
      action: "complete",
      variables: variables_from_hash(form)
    }.to_json
  end

end
