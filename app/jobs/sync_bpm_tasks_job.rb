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
        issue = build_issue_from_task(task)
        task_definition = BpmIntegration::TaskDefinition.by_task_instance(
                                                            task.taskDefinitionKey, task.processDefinitionId).first

        issue.human_task_issue = build_human_task_issue(task, task_definition)

        issue.custom_fields = custom_values_from_task_form_data(task, task_definition)

        if issue.save(validation: false)
          p "[SyncBpmTaskJob - INFO] Issue \##{issue.id} (" + issue.subject + ") salva com sucesso."
        else
          p "[SyncBpmTaskJob - ERROR] " + issue.errors.messages
        end
      rescue => exception
        logger.error exception
        p "[SyncBpmTaskJob - FATAL] " + exception.to_s
      end
    end
  end

  private

  def read_human_tasks
    begin
      BpmTaskService.task_list
    rescue => e
      logger.error e.to_s
      []
    end
  end

  def build_issue_from_task(task)
    parent = Issue.find(get_process_parent_issue_id(task))
    issue = Issue.new
    issue.status_id = Setting.plugin_bpm_integration[:new_status].to_i
    issue.subject = (task.name + " - " + parent.subject).truncate(255)
    issue.description = parent.description
    issue.priority_id = IssuePriority.default.id
    issue.author_id = Setting.plugin_bpm_integration[:bpm_user].to_i
    issue.tracker_id = get_tracker_id(task.processDefinitionId)
    issue.parent_id = parent.id
    issue.assigned_to_id = get_assignee_id(task.assignee)
    issue.project_id = Project.where(identifier: task.formKey).pluck(:id).first || issue.parent.project_id
    issue
  end

  def get_tracker_id(process_id)
    begin
      tracker_process = BpmIntegration::ProcessDefinition.where(process_identifier: process_id).first
      tracker_process.tracker_process_definition.tracker_id
    rescue
      return nil
    end
  end

  def get_process_parent_issue_id(task)
    result = Issue.by_process_instance(task.processInstanceId).pluck(:id)
    if result.empty?
      p "[SyncBpmTaskJob - ERROR] Não foi possível criar a human_task " + task.id
      return nil
    end
    result.first
  end

  def get_assignee_id(task_assignee)
    task_assignee.is_a?(Integer) ? (Principal.where(id: task_assignee.to_i).pluck(:id).first) : nil
  end

  def build_human_task_issue(task, task_definition)
    human_task_issue = BpmIntegration::HumanTaskIssue.new
    human_task_issue.human_task_id = task.id
    human_task_issue.task_definition = task_definition

    human_task_issue
  end

  def custom_values_from_task_form_data(task, task_definition)
    custom_field_values = []
    form_fields_data = BpmTaskService.form_data(task.id)['formProperties']
    task_definition.form_fields.select { |ff| ff.readable }.each do |ff|
      ff_data = form_fields_data.select { |ffd| ffd["id"] == ff.field_id }.first
      custom_field_values << { id: ff.custom_field.id, value: (ff_data["value"] || '') }
    end

    custom_field_values
  end

end
