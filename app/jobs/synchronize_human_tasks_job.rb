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
      issue.project_id = Project.find(task.formKey).id
      user_assigned = User.find_by_login(task.assignee)
      unless (user_assigned = User.find_by_login(task.assignee)).nil?
        issue.assigned_to_id = user_assignee
      end

      # TODO: remove mock
      issue.tracker_id = mock_parse_tracker(task.processDefinitionId)
      issue.author_id = mock_parse_author(task.owner)

      # TODO: parent task
      # issue.parent_id = ???

      if issue.save!(validation: false)
        puts "Issue " + issue.subject + " salva com sucesso"
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
