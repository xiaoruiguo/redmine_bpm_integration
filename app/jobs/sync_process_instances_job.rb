class SyncProcessInstancesJob < ActiveJob::Base
  queue_as :bpm_process_instances

  include Redmine::I18n

  def perform(issue_process_instance = nil)
    if issue_process_instance.nil?
      sync_process_instance_list
    else
      sync_process_instance(issue_process_instance)
    end
  end

  protected


  def bpm_user
    @bpm_user ||= User.find(Setting.plugin_bpm_integration[:bpm_user])
  end


  def sync_process_instance_list
    Delayed::Worker.logger.info "#{self.class} - Sincronizando process_instances"
    BpmIntegration::IssueProcessInstance.where(completed:false).each do |p|
      begin
        sync_process_instance(p)
      rescue => exception
        handle_error(p.issue, exception.message, exception)
      end
    end
    Delayed::Worker.logger.info "#{self.class} - Sincronização de process_instances concluída"
  rescue => exception
    Delayed::Worker.logger.error l('error_process_instance_job')
    Delayed::Worker.logger.error e.message
    exception.backtrace.each { |line| Delayed::Worker.logger.error line }
  end

  def self.reschedule_job
    set(wait: SyncJobsPeriod.process_instance_period).perform_later
    Delayed::Worker.logger.info "#{self.class} - Sincronização de instancias de processos agendada"
  end

  after_perform do |job|
    if job.arguments.empty?
      self.class.reschedule_job
    end
  end

  def sync_process_instance(issue_process_instance)
    #TODO: Tratar erros no Activiti e atualizar para status Erro
    historic_process = BpmProcessInstanceService.historic_process_instance(issue_process_instance.process_instance_id)
    if historic_process && historic_process.endTime.present?
      resolve_issue_process(issue_process_instance, historic_process)
    else
      update_running_status(issue_process_instance, historic_process)
    end
  end

  def resolve_issue_process(issue_process_instance, historic_process)
    update_closing_status(issue_process_instance, historic_process)
    issue = issue_process_instance.issue

    #Seta msg de erro
    if historic_process.deleteReason.present?
      Journal.new(  journalized:  issue,
                           user: bpm_user,
                          notes:  historic_process.deleteReason,
                  private_notes: true).save
    end
    issue_process_instance.completed = true
    issue_process_instance.save
    #TODO: Melhora log abaixo
    Delayed::Worker.logger.info "#{self.class} - Issue \##{issue.id} concluída mediante o fim do processo"
  end

  def update_closing_status(issue_process_instance, historic_process)
    issue_process_instance.update_issue_status_on_close_for_end_event(historic_process.endActivityId)
  end

  def update_running_status(issue_process_instance, historic_process)
    bpm_status_id = BpmProcessInstanceService.process_overall_status_variable(historic_process.id)
    if bpm_status_id
      issue = issue_process_instance.issue
      if bpm_status_id != issue.status_id
        new_status = IssueStatus.find(bpm_status_id)
        issue.init_journal(bpm_user)
        issue.status = new_status
        issue.save!(validate: false)
      end
    end
  end

  def handle_error(issue, msg, e = nil)
    Delayed::Worker.logger.error l('error_process_instance_job')
    Delayed::Worker.logger.error msg
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
    Journal.new(journalized: issue,
                user: bpm_user,
                notes: l('error_process_instance_job') + ":  #{msg}",
                private_notes: true).save
  end
end
