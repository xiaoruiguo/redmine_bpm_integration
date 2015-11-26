class SyncJobsPeriod

  @bpm_task = 20.seconds
  @process_instance = 20.seconds

  def self.bpm_task_period
    @bpm_task
  end

  def self.process_instance_period
    @process_instance
  end

end
