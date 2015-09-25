
module BpmIntegration
  module Patches
    module IssuePatch

      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do
          has_one :human_task_issue, class_name: 'BpmIntegration::HumanTaskIssue', :dependent => :destroy
          has_one :process_instance, class_name: 'BpmIntegration::IssueProcessInstance', :dependent => :destroy
          scope :human_task, -> { joins(:human_task_issue) }

          after_commit :start_process_instance, if: 'self.tracker.is_bpm_process? and !self.is_human_task?'
          before_save :close_human_task
        end
      end

      module InstanceMethods

        def is_human_task?
          !self.human_task_issue.blank?
        end

        def start_process_instance
          self.process_instance ||= BpmIntegration::IssueProcessInstance.new
          self.process_instance.save

          form_fields = self.tracker.process_definition.form_fields
          form_data = form_values(form_fields)
          response = BpmProcessInstanceService.start_process(
              self.tracker.tracker_process_definition.process_definition_key, self.id, form_data
          )
          if response.code != 201
            logger.error response.code + l('msg_process_start_error')
            raise l('msg_process_start_error')
          end
          SynchronizeHumanTasksJob.perform_now()

          # TODO: tratar erro de criação e retornar uma mensagem decente
          self.status_id = Setting.plugin_bpm_integration[:doing_status].to_i

        end

        def close_human_task
          return unless self.is_human_task? && self.status_id == Setting.plugin_bpm_integration[:closed_status].to_i
          if Issue.find(self.id).status_id != Setting.plugin_bpm_integration[:closed_status].to_i
              task_id = self.human_task_issue.human_task_id
              if !task_id.blank?
                response = BpmTaskService.resolve_task(task_id, bpm_form_values)
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
          # TODO: verificar se o processo terminou -> concluir a tarefa original
        end

        def bpm_form_values
          variables = []
          variables
        end

        private

        def form_values(form_fields)
          form_fields.map do |ff|
            field_value = (
              self.custom_field_values.select do |cfv|
                cfv.custom_field_id == ff.custom_field.id
              end
            ).first.value
            field_value = field_value.gsub('=>',':') if (ff.custom_field.field_format == "grid")
            { ff.field_id => field_value }
          end.reduce(&:merge)
        end
      end
    end
  end
end
