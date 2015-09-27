class SyncBpmTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize_tasks
  end

  protected

  def synchronize_tasks
    read_human_tasks.each do |task|
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

      # TODO: validar atribuição ao principal
      if task.assignee.is_a?(Integer) && !(user_assigned = Principal.where(id: task.assignee.to_i).first).blank?
        issue.assigned_to_id = user_assigned.id
      end

      # TODO: associar ao projeto da tarefa pai caso o formkey seja nulo (buscar pela businessKey)
      issue.project_id = get_task_project(task)
      next if issue.project_id.blank?

      # TODO: remover o mock do tracker_id: buscar pela configuração da tarefa
      issue.tracker_id = mock_parse_tracker(task.processDefinitionId)

      # TODO: associar a tarefa pai (buscar pela businessKey)
      # issue.parent_id = ???

      if issue.save!(validation: false)
        p "[INFO] Issue " + issue.subject + " salva com sucesso."
      end
    end
  end

  def get_task_project(task)
    project = Project.where(id: task.formKey).first
    return project unless project.blank?
    process_instance = BpmProcessInstanceService.process_instance(task.processInstanceId)
    if logger.error.blank?
      p "[ERROR] Não foi possível criar a human_task " + task.id
      return nil
    end
    Issue.find(process_instance.businessKey.to_i).project_id
  end

  def read_human_tasks
    BpmTaskService.task_list
  end

  def mock_parse_tracker(process_id)
    return 1
  end

end
