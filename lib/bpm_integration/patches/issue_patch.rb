
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
          return nil if Issue.find(self.id).status.is_closed || self.human_task_issue.human_task_id.blank?
          begin
            response = BpmTaskService.resolve_task(self)
          rescue => error
            handle_error(l('msg_issue_closed_error'), Issue.find(self.id).id, error)

            return false
          end
          if response != nil && response.code == 200
            logger.info "#{self.class} - Tarefa completada no BPMS"

            #JOB - Atualiza tarefas de um processo
            SyncBpmTasksJob.perform_now(self.parent.process_instance.process_instance_id)

            self.parent.reload

            #JOB - Atualiza process_instances
            SyncProcessInstancesJob.perform_now(self.parent.process_instance)

          else
            logger.error "#{self.class} - Ocorreu um problema ao completar tarefa no BPMS. " + response.response.code + " - " + response.response.msg
            begin
              logger.error response["exception"] if response.is_a? Hash
            rescue;end
          end
        end

        def handle_error(msg_code, id, error = nil, response = nil, print_error = false)
          logger.error self.class
          print_msg = msg_code.to_s + " " + error.message.to_s
          logger.error error.message
          error.backtrace.each { |line| logger.error line }

          if print_error == true
            msg_code = print_msg
          end

          errors[:base] << msg_code
        end
      end
    end
  end
end
