# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task stop_sync_bpm: :environment do
        Delayed::Job.where("queue = 'bpm_process_instances' or queue = 'bpm_tasks'").destroy_all
      end
    end
  end
end
