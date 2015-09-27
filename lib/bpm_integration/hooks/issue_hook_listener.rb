class IssueHookListener < Redmine::Hook::ViewListener
    def view_issues_index_bottom(context={ })
      require_relative '../../../app/jobs/sync_bpm_tasks_job'
      require_relative '../../../app/jobs/sync_process_instances_job'
      SyncBpmTasksJob.perform_now
      SyncProcessInstancesJob.perform_now
      ""
    end
end
