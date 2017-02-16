
module BpmIntegration
  module Patches
    module IssuePatch

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

          after_commit :start_process_instance, if: 'self.tracker.is_bpm_process? && self.parent.try(:tracker_id) != tracker_id', on: :create
          before_save :close_human_task, if: 'self.status.is_closed and self.is_human_task?'

          alias_method_chain :available_custom_fields, :bpm_form_fields
          alias_method_chain :read_only_attribute_names, :bpm_form_fields
          alias_method_chain :required_attribute_names, :bpm_form_fields
          alias_method_chain :tracker=, :bpm_form_fields

        end
      end

      module InstanceMethods

        def is_human_task?
          !self.human_task_issue.blank?
        end

        def tracker_with_bpm_form_fields= (new_tracker)
          @bpm_form_fields = nil if self.tracker != new_tracker
          self.tracker_without_bpm_form_fields = new_tracker
        end

        def bpm_form_fields
          if is_human_task?
            @bpm_form_fields ||= human_task_issue.task_definition.form_fields
          elsif tracker && tracker.is_bpm_process?
            @bpm_form_fields ||= tracker.process_definition.form_fields
          else
            []
          end
        end

        def available_custom_fields_with_bpm_form_fields
          custom_fields = available_custom_fields_without_bpm_form_fields
          custom_fields = (custom_fields | available_bpm_form_fields(bpm_form_fields)) unless bpm_form_fields.blank?
          custom_fields
        end

        def available_bpm_form_fields(form_fields)
          form_fields.select{ |ff| ff.readable }.map(&:custom_field)
        end

        def read_only_attribute_names_with_bpm_form_fields(user = nil)
          cf_names = read_only_attribute_names_without_bpm_form_fields(user)

          return cf_names if (user || User.current).admin?

          cf_names = (cf_names | read_only_bpm_form_fields_names(bpm_form_fields, user)) unless bpm_form_fields.blank?
          cf_names
        end

        def read_only_bpm_form_fields_names(form_fields, user = nil)
          form_fields.select{ |ff| !ff.writable }.map{ |ff| ff.custom_field.id.to_s }
        end

        def required_attribute_names_with_bpm_form_fields(user = nil)
          cf_names = required_attribute_names_without_bpm_form_fields(user)
          cf_names = (cf_names | required_bpm_form_fields_names(bpm_form_fields, user)) unless bpm_form_fields.blank?
          cf_names
        end

        def required_bpm_form_fields_names(form_fields, user = nil)
          form_fields.select{ |ff| ff.required }.map{ |ff| ff.custom_field.id.to_s }
        end

        def start_process_instance
          StartProcessJob.perform_now(self.id)
        end

        def close_human_task
          return nil if self.status_was.is_closed || self.human_task_issue.human_task_id.blank?
          begin
            response = nil
            Issue.transaction do
              update_process_parent_issue_fields

              response = BpmTaskService.resolve_task(self)
              log(:info, "Resposta do Activiti para fechar tarefa: #{response.response.code} - #{response.response.msg}")

              if (response != nil) && (response.code != 200)
                log(:error, "Ocorreu um problema ao completar tarefa no BPMS.")
                log(:error, response["exception"]) if response.is_a?(Hash) && response["exception"].present?
              end
            end
          rescue => error
            handle_error(l('msg_issue_closed_error'), error)

            return false
          end
          if (response != nil) && (response.code == 200)
            log(:info, "Tarefa completada no BPMS")

            synchronize_process_tasks

            log(:info, "Tarefas sincronizadas do BPMS")

            self.parent.reload

            synchronize_process_status

            log(:info, "Processo sincronizado com BPMS")
          end
        end

        def handle_error(msg_code, error, print_error = false)
          log(:error, self.class)
          print_msg = "#{msg_code.to_s} #{error.message.to_s}"
          log(:error, error.message)
          error.backtrace.each { |line| logger.error line }

          if print_error
            msg_code = print_msg
          end

          errors[:base] << msg_code
        end

        def log(log_level, msg)
          logger.send(log_level, "#{Time.zone.now.to_formatted_s} | #{logger.object_id} | #{self.class} - " +
                          "(issue: #{self.id} | task: #{self.human_task_issue.human_task_id}) - #{msg}")
        end

        def update_process_parent_issue_fields
          process_issue = self.parent

          process_issue.init_journal(User.find(Setting.plugin_bpm_integration[:bpm_user]))

          process_issue.custom_field_values = self.custom_field_values
              .map { |cfv| {cfv.custom_field.id.to_s => cfv.value } }
              .reduce({}, &:merge)

          process_issue.save(validate: false)
        end

        def synchronize_process_status
          SyncProcessInstancesJob.perform_now(self.parent.process_instance)
        end

        def synchronize_process_tasks
          SyncBpmTasksJob.perform_now(self.parent.process_instance.process_instance_id)
        end

      end
    end
  end
end
