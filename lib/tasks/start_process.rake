# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task start_process: :environment do
          require_relative '../../app/jobs/start_process_job'
          StartProcessJob.perform_now(69)
      end
    end
  end
end
