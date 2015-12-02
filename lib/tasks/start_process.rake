# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task start_process: :environment do |t, args|
        require_relative '../../app/jobs/start_process_job'
        Tracker.select(&:is_bpm_process?).map(&:issues).reduce([], &:concat)
                .select { |i| !i.is_human_task? && i.process_instance.blank? }.each do |issue|
          StartProcessJob.perform_now(issue.id)
        end
      end
    end
  end
end
