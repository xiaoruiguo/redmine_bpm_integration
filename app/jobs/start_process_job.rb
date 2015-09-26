class StartProcessJob < ActiveJob::Base
  queue_as :default

  include Redmine::I18n

  def perform(issue_id)
    start_bpm_process(issue_id)
  end

  protected

  def start_bpm_process(issue_id)
    begin
      issue = Issue.find(issue_id)
      form_fields = issue.tracker.process_definition.form_fields
      form_data = form_values(form_fields)
      response = BpmProcessInstanceService.start_process(
          issue.tracker.tracker_process_definition.process_definition_key, issue.id, form_data
      )
      if response.code != 201
        handle_error(issue, response)
      else
        issue.status_id = Setting.plugin_bpm_integration[:doing_status].to_i
        issue.save(validate:false)
        SyncBpmTasksJob.perform_now()
      end
    rescue => exception
      handle_error(issue, exception)
    end
  end

  def form_values(form_fields)
    form_fields.map do |ff|
      field_value = (
        issue.custom_field_values.select do |cfv|
          cfv.custom_field_id == ff.custom_field.id
        end
      ).first.value
      field_value = field_value.gsub('=>',':') if (ff.custom_field.field_format == "grid")
      { ff.field_id => field_value }
    end.reduce(&:merge)
  end

  def handle_error(issue, exception)
    logger.error exception
    issue.status_id = Setting.plugin_bpm_integration[:error_status].to_i
    issue.init_journal(User.find(Setting.plugin_bpm_integration[:bpm_user]), l('msg_process_start_error'))
    issue.save(validate:false)
  end

end
