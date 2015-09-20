class SynchronizeHumanTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize_tasks
    # SynchronizeHumanTasksJob.perform_later()
  end

  protected

  def synchronize_tasks
    read_human_tasks.each do |task|
      return if BpmIntegration::HumanTaskIssue.where(human_task_id:task.id).first
      issue = Issue.new
      issue.human_task_issue = BpmIntegration::HumanTaskIssue.new
      issue.human_task_issue.human_task_id = task.id
      issue.description = task.description
      issue.project_id = mock_parse_project(task.formKey)
      issue.due_date = task.dueDate
      issue.status_id = Setting.plugin_bpm_integration[:new_status].to_i
      issue.tracker_id = mock_parse_tracker(task.processDefinitionId)
      issue.author_id = mock_parse_author(task.owner)
      issue.assigned_to_id = task.assignee
      issue.subject = task.name
      #TODO: Pegar o parent
      if issue.save!(validation: false)
        puts "Issue " + issue.subject + " salva com sucesso"
      end
    end
  end

  def read_human_tasks
    BpmTaskService.bpm_tasks
  end

  def mock_parse_author(owner)
    return 1
  end

  def mock_human_tasks
    t = BpmTask.new
    t.description = 'Description'
    tasks = []
    tasks << t
    tasks
  end

  def mock_parse_tracker(process_id)
    return 1
  end

  def mock_parse_project(project_id)
    return 1
  end
end
