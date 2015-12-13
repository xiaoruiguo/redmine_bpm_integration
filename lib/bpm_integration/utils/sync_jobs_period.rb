class SyncJobsPeriod

  @bpm_task = 60.seconds
  @process_instance = 60.seconds

  def self.bpm_task_period
    @bpm_task
  end

  def self.process_instance_period
    @process_instance
  end

end
