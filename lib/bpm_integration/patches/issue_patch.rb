module BpmIntegration
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do
          has_one :human_task_issue, class_name: 'BpmIntegration::HumanTaskIssue', :dependent => :destroy
          scope :human_task, -> { joins(:human_task_issue) }

          before_save :close_human_task, if: '!self.human_task_issue.blank? && self.status_id == Setting.plugin_bpm_integration[:closed_status].to_i'
          before_save :start_process_instance, if: 'self.tracker.is_bpm_process?'
        end
      end

      module InstanceMethods

        def start_process_instance
          BpmProcessService.start_process(self.tracker.tracker_process_relation.process_definition_key, {})
        end

        def close_human_task
          if Issue.find(self.id).status_id != Setting.plugin_bpm_integration[:closed_status].to_i
              task_id = self.human_task_issue.human_task_id
              if !task_id.blank?
                response = BpmTaskService.resolve_task(task_id,bpm_form_values)
                if response != nil && response.code == 200
                  puts "Tarefa completada no BPMS"
                else
                  puts "Ocorreu um problema ao completar tarefa no BPMS. " + response.response.code + " - " + response.response.msg
                  begin
                    puts response["exception"] if response.is_a? Hash
                  rescue;end
                end
              end
          end
        end

        def bpm_form_values
          variables = []
          variables
        end
      end
    end
  end
end
