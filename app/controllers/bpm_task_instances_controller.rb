class BpmTaskInstancesController < BpmController

  require_relative '../jobs/synchronize_human_tasks_job.rb'

  def sync
      SynchronizeHumanTasksJob.perform_now
  end

end
