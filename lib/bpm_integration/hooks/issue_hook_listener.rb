class IssueHookListener < Redmine::Hook::ViewListener
    def view_issues_index_bottom(context={ })
      require_relative '../../../app/jobs/sync_bpm_tasks_job'
      SyncBpmTasksJob.perform_now
      ""
    end
end
