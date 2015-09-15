class SynchronizeHumanTasksJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize_tasks
    # SynchronizeHumanTasksJob.perform_later()
  end

  protected

  def synchronize_tasks
    read_human_tasks.each do |task|
      issue = Issue.new
      issue.id = task.id
      issue.description = task.description
      issue.project_id = 1
      issue.status_id = 1
      issue.tracker_id = mock_parse_tracker(task.processDefinitionId)
      issue.author_id = 6
      # issue.subject = task.name
      issue.subject = task.description
      if issue.save(validation: false)
        puts "Issue " + issue.subject + " salva com sucesso"
      end
    end
  end

  def read_human_tasks
    mock_human_tasks
    # ActivitiBpmService.new.bpm_tasks
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
end
