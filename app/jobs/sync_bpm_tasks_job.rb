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
        issue.human_task_issue.task_definition = BpmIntegration::TaskDefinition.by_task_instance(
                                                            task.taskDefinitionKey, task.processDefinitionId).first
        issue.status_id = Setting.plugin_bpm_integration[:new_status].to_i
        issue.subject = task.name
        issue.description = task.description
        issue.priority_id = IssuePriority.default.id
        issue.author_id = Setting.plugin_bpm_integration[:bpm_user].to_i

        if task.assignee.is_a?(Integer) && !(user_assigned = Principal.where(id: task.assignee.to_i).first).blank?
          issue.assigned_to_id = user_assigned.id
        end
        process_parent_issue = get_process_parent_issue(task)
        issue.project_id = process_parent_issue.project_id
        issue.parent = process_parent_issue

        issue.tracker_id = get_tracker(task.processDefinitionId)

        if issue.save(validation: false)
            p "[INFO] Issue " + issue.subject + " salva com sucesso."
        else
          p "[ERROR] " + issue.errors.messages
        end
      rescue => exception
        logger.error exception
        p exception
      end
    end
  end

  def get_process_parent_issue(task)
    project = Project.where(id: task.formKey).first
    return project unless project.blank?
    result = Issue.by_process_instance(task.processInstanceId)
    if result.empty?
      p "[ERROR] Não foi possível criar a human_task " + task.id
      return nil
    end
    result.first
  end

  def read_human_tasks
    BpmTaskService.task_list
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
