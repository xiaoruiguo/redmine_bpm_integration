class BpmTaskInstancesController < BpmController

  require_relative '../jobs/sync_bpm_tasks_job.rb'

  def sync
      SyncBpmTasksJob.perform_now
  end

end
