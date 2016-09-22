class BpmTaskInstancesController < BpmController

  def sync
      SyncBpmTasksJob.perform_now
  end

end
