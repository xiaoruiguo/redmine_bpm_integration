# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :bpm_integration do
      task sync_process_definitions: :environment do
          SyncProcessDefinitionsJob.perform_now
      end
    end
  end
end
