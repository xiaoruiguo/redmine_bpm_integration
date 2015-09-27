class SyncBpmTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize_tasks
  end

  protected

  def synchronize_tasks
    read_human_tasks.each do |task|
      begin
        next if BpmIntegration::HumanTaskIssue.where(human_task_id:task.id).first
        issue = Issue.new
        issue.human_task_issue = BpmIntegration::HumanTaskIssue.new
        issue.human_task_issue.human_task_id = task.id
        task_definition = BpmIntegration::TaskDefinition.by_task_instance(
                                                            task.taskDefinitionKey, task.processDefinitionId).first
        issue.human_task_issue.task_definition = task_definition
        issue.status_id = Setting.plugin_bpm_integration[:new_status].to_i
        issue.subject = task.name
        issue.description = task.description
        issue.priority_id = IssuePriority.default.id
        issue.author_id = Setting.plugin_bpm_integration[:bpm_user].to_i

        if task.assignee.is_a?(Integer) && !(user_assigned = Principal.where(id: task.assignee.to_i).first).blank?
          issue.assigned_to_id = user_assigned.id
        end
        parent_issue = get_process_parent_issue(task)
        issue.parent_id = parent_issue.id
        issue.project_id = Project.where(identifier: task.formKey).first || issue.parent.project_id

        issue.tracker_id = get_tracker(task.processDefinitionId)

        form_fields_data = task_form_data(task.id)['formProperties']
        custom_field_values = []
        task_definition.form_fields.each do |ff|
          ff_data = form_fields_data.select { |ffd| ffd["id"] == ff.field_id }.first
          custom_field_values << { id: ff.custom_field.id, value: ff_data["value"] }
        end
        issue.custom_fields = custom_field_values

        if issue.save(validation: false)
          p "[SyncBpmTaskJob - INFO] Issue \##{issue.id} (" + issue.subject + ") salva com sucesso."
        else
          p "[SyncBpmTaskJob - ERROR] " + issue.errors.messages
        end
      rescue => exception
        logger.error exception
        p "[SyncBpmTaskJob - FATAL]" + exception.to_s
      end
    end
  end

  def get_process_parent_issue(task)
    result = Issue.by_process_instance(task.processInstanceId)
    if result.empty?
      p "[SyncBpmTaskJob - ERROR] Não foi possível criar a human_task " + task.id
      return nil
    end
    result.first
  end

  def read_human_tasks
    begin
      BpmTaskService.task_list
    rescue => e
      logger.error e.to_s
      []
    end
  end

  def task_form_data(taskId)
    BpmTaskService.form_data(taskId)
  end

  def get_tracker(process_id)
    begin
      tracker_process = BpmIntegration::ProcessDefinition.where(process_identifier: process_id).first
      tracker_process.tracker_process_definition.tracker_id
    rescue
      return nil
    end
  end

end
