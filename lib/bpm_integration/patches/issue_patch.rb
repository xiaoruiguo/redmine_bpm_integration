
module BpmIntegration
  module Patches
    module IssuePatch

      require_relative '../../../app/jobs/sync_bpm_tasks_job'
      require_relative '../../../app/jobs/sync_process_instances_job'

      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do
          has_one :human_task_issue, class_name: 'BpmIntegration::HumanTaskIssue', autosave: true, :dependent => :destroy
          scope :human_task, -> { joins(:human_task_issue) }

          has_one :process_instance, class_name: 'BpmIntegration::IssueProcessInstance', :dependent => :destroy
          scope :by_process_instance, -> (process_instance_id){
                                            joins(:process_instance)
                                            .where(bpmint_issue_process_instances:{process_instance_id: process_instance_id})
                                          }

          after_commit :start_process_instance, if: 'self.tracker.is_bpm_process? and !self.is_human_task?', on: :create
          before_save :close_human_task

          alias_method_chain :available_custom_fields, :bpm_form_fields
          alias_method_chain :read_only_attribute_names, :bpm_form_fields

        end
      end

      module InstanceMethods

        def is_human_task?
          !self.human_task_issue.blank?
        end

        def available_custom_fields_with_bpm_form_fields
          custom_fields = available_custom_fields_without_bpm_form_fields
          custom_fields = custom_fields | human_task_issue.task_definition.form_fields
                .select{ |ff| ff.readable }.map(&:custom_field) if is_human_task?
          custom_fields = custom_fields | tracker.process_definition.form_fields
                .select{ |ff| ff.readable }
                .map(&:custom_field) if !is_human_task? && tracker && tracker.is_bpm_process?
          custom_fields
        end

        def read_only_attribute_names_with_bpm_form_fields(user = nil)
          custom_fields = read_only_attribute_names_without_bpm_form_fields(user)
          custom_fields = custom_fields | human_task_issue.task_definition.form_fields
                .select{ |ff| !ff.writable }.map{ |ff| ff.custom_field.id.to_s } if is_human_task?
          custom_fields = custom_fields | tracker.process_definition.form_fields
                .select{ |ff| !ff.writable }
                .map{ |ff| ff.custom_field.id.to_s } if !is_human_task? && tracker && tracker.is_bpm_process?
          custom_fields
        end

        def start_process_instance
          require_relative('../../../app/jobs/start_process_job')
          #JOB - Inicia processo
          StartProcessJob.perform_now(self.id)
        end

        def close_human_task
          return unless self.is_human_task? && self.status_id == Setting.plugin_bpm_integration[:closed_status].to_i
          if Issue.find(self.id).status_id != Setting.plugin_bpm_integration[:closed_status].to_i
              task_id = self.human_task_issue.human_task_id
              if !task_id.blank?
                form_fields = self.human_task_issue.task_definition.form_fields
                form_data = form_values(form_fields)
                response = BpmTaskService.resolve_task(task_id, form_data)
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

          #JOB - Atualiza tarefas de um processo
          SyncBpmTasksJob.perform_now(self.parent.process_instance.process_instance_id)

          #JOB - Atualiza process_instances
          SyncProcessInstancesJob.perform_now(self.parent.process_instance)
        end

        private

        def form_values(form_fields)
          form_fields ||= []
          hash_fields = form_fields.map do |ff|
            field_value = (
              self.custom_field_values.select do |cfv|
                ff.custom_field && (cfv.custom_field_id == ff.custom_field.id)
              end
            ).first.try(&:value)
            if field_value
              field_value = field_value.gsub('=>',':') if (ff.custom_field.field_format == "grid")
            end
            { ff.field_id => field_value }
          end
          hash_fields.reduce(&:merge)
        end

      end
    end
  end
end
