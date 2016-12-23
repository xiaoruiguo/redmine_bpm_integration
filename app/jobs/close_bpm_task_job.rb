class CloseBpmTaskJob < ActiveJob::Base
  queue_as :bpmint_close_task

  include Redmine::I18n

  def perform(issue, status_id, retry_on_error = true)
    if issue.is_a? Integer
      @issue = Issue.find(issue)
    elsif issue.is_a? Issue
      @issue = issue
    else
      raise ArgumentError, 'First argument must be an issue or an issue id'
    end

    return if @issue.status_id != status_id

    @retry_on_error = retry_on_error
    @status_id = status_id

    begin
      response = nil
      Issue.transaction do
        update_process_parent_issue_fields

        response = BpmTaskService.resolve_task(@issue)
        log(:info, "Resposta do Activiti para fechar tarefa: #{response.response.code} - #{response.response.msg}")

        if (response != nil) && (response.code == 200)
          log(:info, "Tarefa completada no BPMS")
        else
          log(:error, "Ocorreu um problema ao completar tarefa no BPMS.")
          log(:error, response["exception"]) if response.is_a?(Hash) && response["exception"].present?
        end
      end
    rescue => error
      handle_error(error)

      return false
    end

    begin
      synchronize_process_tasks

      log(:info, "Tarefas sincronizadas do BPMS")

      @issue.parent.reload

      synchronize_process_status

      log(:info, "Processo sincronizado com BPMS")
    rescue => error
      handle_error(error)
    end

    return true
  end

  def self.reschedule_job(issue, status_id, retry_on_error = true)
    set(wait: SyncJobsPeriod.reschedule_close_task).perform_later(issue.id, status_id, retry_on_error) if retry_on_error
  end

  protected

  def handle_error(error)
    self.class.reschedule_job(@issue, @status_id, @retry_on_error)

    log(:error, error.message)
    error.backtrace.each { |line| log(:error, line) }
  end

  def log(log_level, msg)
    Delayed::Worker.logger.send(log_level, "#{Time.zone.now.to_formatted_s} | #{logger.local_log_id} | #{self.class} - " +
        "(issue: #{@issue.id} | task: #{@issue.human_task_issue.human_task_id}) - #{msg}")
  end

  def update_process_parent_issue_fields
    process_issue = @issue.parent

    process_issue.init_journal(User.find(Setting.plugin_bpm_integration[:bpm_user]))

    process_issue.custom_field_values = @issue.custom_field_values
                                            .map { |cfv| {cfv.custom_field.id.to_s => cfv.value } }
                                            .reduce({}, &:merge)

    process_issue.save(validate: false)
  end

  def synchronize_process_status
    SyncProcessInstancesJob.perform_now(@issue.parent.process_instance)
  end

  def synchronize_process_tasks
    SyncBpmTasksJob.perform_now(@issue.parent.process_instance.process_instance_id)
  end

end
