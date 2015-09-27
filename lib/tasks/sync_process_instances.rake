# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task sync_process_instances: :environment do
          require_relative '../../app/jobs/sync_process_instances_job'
          SyncProcessInstancesJob.perform_now()
      end
    end
  end
end
