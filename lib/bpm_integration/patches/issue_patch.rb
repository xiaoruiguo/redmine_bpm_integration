
module BpmIntegration
  module Patches
    module IssuePatch

      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do
          has_one :human_task_issue, class_name: 'BpmIntegration::HumanTaskIssue', :dependent => :destroy
          scope :human_task, -> { joins(:human_task_issue) }

          after_commit :start_process_instance, if: 'self.tracker.is_bpm_process? and !self.is_human_task?', on: :create
          before_save :close_human_task
        end
      end

      module InstanceMethods

        def is_human_task?
          !self.human_task_issue.blank?
        end

        def start_process_instance
          require_relative('../../../app/jobs/start_process_job')
          StartProcessJob.perform_now(self.id)
        end

        def close_human_task
          return unless self.is_human_task? && self.status_id == Setting.plugin_bpm_integration[:closed_status].to_i
          if Issue.find(self.id).status_id != Setting.plugin_bpm_integration[:closed_status].to_i
              task_id = self.human_task_issue.human_task_id
              if !task_id.blank?
                response = BpmTaskService.resolve_task(task_id, bpm_form_values)
                if response != nil && response.code == 200
                  puts "Tarefa Ocorreu um erro ao tentar iniciar um novo processo.completada no BPMS"
                else
                  puts "Ocorreu um problema ao completar tarefa no BPMS. " + response.response.code + " - " + response.response.msg
                  begin
                    puts response["exception"] if response.is_a? Hash
                  rescue;end
                end
              end
          end
          # TODO: verificar se o processo terminou -> concluir a tarefa original
        end

        def bpm_form_values
          variables = []
          variables
        end

        private


      end
    end
  end
end
