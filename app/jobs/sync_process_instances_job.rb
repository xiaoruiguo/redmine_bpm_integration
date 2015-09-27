class SyncProcessInstancesJob < ActiveJob::Base
  queue_as :default

  include Redmine::I18n

  def perform
    sync_process_instance_list
  end

  protected

  def sync_process_instance_list
    BpmIntegration::IssueProcessInstance.where(completed:false).each do |p|
      begin
        sync_process_instance(p)
      rescue => exception
        handle_error exception
      end
    end
  end

  def sync_process_instance(issue_process_instance)
    historic_process = BpmProcessInstanceService.historic_process_instance(issue_process_instance.process_instance_id)
    resolve_issue_process(issue_process_instance,historic_process) unless historic_process.blank? || historic_process.endTime.blank?
  end

  def resolve_issue_process(issue_process_instance, historic_process)
    issue = Issue.find(issue_process_instance.issue_id)
    issue.status_id = Setting.plugin_bpm_integration[:closed_status].to_i
    issue.save!(validate:false)
    if historic_process.deleteReason
      user = User.find(Setting.plugin_bpm_integration[:bpm_user])
      Journal.new(:journalized => issue, :user => user, :notes => historic_process.deleteReason, :private_notes => true).save
    end
    issue_process_instance.completed = true
    issue_process_instance.save
    p "[INFO] Issue concluída mediante o fim do processo"
  end

  def handle_error(exception)
    logger.error exception
    p "[ERROR]" + exception.to_s
  end
end
