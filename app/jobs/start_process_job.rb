class StartProcessJob < ActiveJob::Base
  queue_as :default

  include Redmine::I18n

  def perform(issue_id)
    start_bpm_process(issue_id)
  end

  protected

  def start_bpm_process(issue_id)
    issue = Issue.find(issue_id)
    begin
      form_fields = issue.tracker.process_definition.form_fields
      form_data = form_values(form_fields, issue)
      response = BpmProcessInstanceService.start_process(
          issue.tracker.tracker_process_definition.process_definition_key, issue.id, form_data
      )
      if response && response.id
        issue.reload
        issue.process_instance ||= BpmIntegration::IssueProcessInstance.new
        issue.process_instance.process_instance_id = response.id
        issue.process_instance.process_definition = issue.tracker.process_definition
        issue.process_instance.completed = response.completed
        issue.process_instance.save!(validate:false)
        issue.status_id = response.completed ?
                            Setting.plugin_bpm_integration[:closed_status].to_i :
                            Setting.plugin_bpm_integration[:doing_status].to_i

        issue.save!(validate:false)

        Delayed::Worker.logger.info "#{self.class} - Issue \##{issue.id} - Processo " + issue.process_instance.process_instance_id.to_s + " iniciado com sucesso!"

        #JOB - Atualiza tarefas de um processo
        SyncBpmTasksJob.perform_now(issue.process_instance.process_instance_id)
      else
        handle_error(issue, "Response nula")
      end
    rescue => exception
      handle_error(issue, exception.message, exception)
    end
  end

  def form_values(form_fields, issue)
    form_fields ||= []
    hash_fields = form_fields.map do |ff|
      field_value = (
        issue.custom_field_values.select do |cfv|
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

  def handle_error(issue, msg, e = nil)
    Delayed::Worker.logger.error l('error_process_start')
    Delayed::Worker.logger.error msg
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
    user = User.find(Setting.plugin_bpm_integration[:bpm_user])
    Journal.new(:journalized => issue, :user => user, :notes => l('error_process_start') + ":  #{msg}", :private_notes => true).save
  end

end
