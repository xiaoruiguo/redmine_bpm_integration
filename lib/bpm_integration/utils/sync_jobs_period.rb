class SyncJobsPeriod

  @bpm_task = 60.seconds
  @process_instance = 60.seconds
  @reschedule_start_process_on_error = 5.minutes

  def self.bpm_task_period
    @bpm_task
  end

  def self.process_instance_period
    @process_instance
  end

  def self.reschedule_start_process_on_error
    @reschedule_start_process_on_error
  end

end
