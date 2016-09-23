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
      process_definition_version = issue.tracker.process_active_version
      form_data = form_values(process_definition_version.form_fields, issue)
      constants = process_constants(process_definition_version.constants)
      variables = form_data.merge(constants)
      process = BpmProcessInstanceService.start_process(
        process_definition_version.process_definition.key, issue.id, variables
      )
      issue.reload
      issue.process_instance ||= BpmIntegration::IssueProcessInstance.new
      issue.process_instance.process_instance_id = process.id
      issue.process_instance.process_definition_version = process_definition_version
      issue.process_instance.completed = process.completed
      issue.process_instance.save!(validate:false)

      if process.completed
        issue.process_instance = Setting.plugin_bpm_integration[:closed_status].to_i
      else
        issue.status_id = process.status_id_variable || Setting.plugin_bpm_integration[:doing_status].to_i
      end

      issue.save!(validate:false)

      Delayed::Worker.logger.info "#{self.class} - Issue \##{issue.id} - Processo " + issue.process_instance.process_instance_id.to_s + " iniciado com sucesso!"

      #JOB - Atualiza tarefas de um processo
      SyncBpmTasksJob.perform_now(issue.process_instance.process_instance_id)
    rescue => exception
      handle_error(issue, exception)
    end
  end

  private

  def process_constants(constants)
    return {} if constants.blank?
    constants.map { |c| { c.identifier => c.value } }.reduce(&:merge)
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
    hash_fields.reduce(&:merge) || {}
  end

  def handle_error(issue, e)
    Delayed::Worker.logger.error l('error_process_start')
    Delayed::Worker.logger.error e.message
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
    Delayed::Worker.logger.error "\n\n"
    user = User.find(Setting.plugin_bpm_integration[:bpm_user])
    Journal.new(:journalized => issue, :user => user, :notes => l('error_process_start') + ":  #{e.message}", :private_notes => true).save
  end

end
