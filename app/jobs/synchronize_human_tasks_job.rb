class SynchronizeHumanTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize_tasks
  end

  protected

  def synchronize_tasks
    read_human_tasks.each do |task|
      return if BpmIntegration::HumanTaskIssue.where(human_task_id:task.id).first
      issue = Issue.new
      issue.human_task_issue = BpmIntegration::HumanTaskIssue.new
      issue.human_task_issue.human_task_id = task.id
      issue.status_id = Setting.plugin_bpm_integration[:new_status].to_i
      issue.subject = task.name
      issue.description = task.description
      issue.priority_id = IssuePriority.default.id

      # TODO: validar atribuição ao principal
      if task.assignee.is_a?(Integer) && !(user_assigned = Principal.where(id: task.assignee.to_i).first).blank?
        issue.assigned_to_id = user_assigned.id
      end

      # TODO: associar ao projeto da tarefa pai caso o formkey seja nulo (buscar pela businessKey)
      issue.project_id = Project.find(task.formKey).id

      # TODO: remover o mock do tracker_id: buscar pela configuração da tarefa
      issue.tracker_id = mock_parse_tracker(task.processDefinitionId)

      # TODO: remover o mock do author_id: associar a um usuário de serviço criado no script de migração
      issue.author_id = mock_parse_author(task.owner)

      # TODO: associar a tarefa pai (buscar pela businessKey)
      # issue.parent_id = ???

      if issue.save!(validation: false)
        puts "Issue " + issue.subject + " salva com sucesso."
      end
    end
  end

  def read_human_tasks
    BpmTaskService.task_list
  end

  def mock_parse_author(owner)
    return 1
  end

  def mock_parse_tracker(process_id)
    return 1
  end

end
