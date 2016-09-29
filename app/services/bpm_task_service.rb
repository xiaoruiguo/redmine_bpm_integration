class BpmTaskService < ActivitiBpmService

  require_relative '../models/bpm_task'

  def self.task_list(process_instance_id = nil)
    tasks_list_path = '/runtime/tasks'
    size = 100
    start = 0

    tasks = []
    loop do
      params = {
          size: size,
          processInstanceId: process_instance_id,
          start: start
      }.compact.map { |k, v| "#{k}=#{v}" }.join('&')

      hash_bpm_tasks = get("#{tasks_list_path}?#{params}", basic_auth: @@auth)
      tasks += hash_bpm_tasks['data'].map { |t| BpmTask.new(t) }

      start += size
      break if start >= hash_bpm_tasks['total']
    end

    tasks
  end

  def self.update_task_default_fields(task_id, issue)
    put(
      '/runtime/tasks/' + task_id,
      basic_auth: @@auth,
      body: update_default_fields_request_body(issue),
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.resolve_task(issue)
    task_id = issue.human_task_issue.human_task_id
    response = update_task_default_fields(task_id, issue)
    return response if response.blank? || response.code.blank? || response.code != 200

    variables = form_values(issue)
    post(
      '/runtime/tasks/' + task_id,
      basic_auth: @@auth,
      body: resolve_task_request_body(variables, issue),
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

  def self.resolve_task_request_body(form, issue)
    {
      action: "complete",
      variables: variables_from_hash(form)
    }.to_json
  end

  def self.update_default_fields_request_body(issue)
    {
      assignee: issue.assigned_to_id,
      dueDate: issue.due_date,
      owner: issue.author_id,
      priority: issue.priority_id,
      category: issue.category_id,
      description: issue.description
    }.to_json
  end

  def self.form_values(issue)
    form_fields = issue.human_task_issue.task_definition.form_fields.includes(:custom_field)
    form_fields ||= []

    hash_fields = form_fields.map do |ff|
      field_value = (
        issue.custom_field_values.select do |cfv|
          ff.custom_field && (cfv.custom_field_id == ff.custom_field.id)
        end
      ).first.try(&:value)
      if field_value
        #Trata valores dos campos grid
        field_value = field_value.gsub('=>',':') if (ff.custom_field.field_format == "grid")
      end
      { ff.field_id => field_value }
    end
    hash_fields = hash_fields.reduce({},&:merge)
    hash_fields.merge!(default_fields_form_values(issue))
    hash_fields
  end
end
