# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task sync_bpm_tasks: :environment do
          require_relative '../../app/jobs/sync_bpm_tasks_job'
          SyncBpmTasksJob.perform_now()
      end
    end
  end
end
