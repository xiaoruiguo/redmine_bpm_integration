class SyncBpmTasksJob < ActiveJob::Base
  queue_as :bpm_tasks

  include Redmine::I18n

  def perform(process_instance_id = nil)
    synchronize_tasks(process_instance_id)
  end

  protected

  def synchronize_tasks(process_instance_id)
    Delayed::Worker.logger.info "#{self.class} - Sincronizando bpm_tasks para criar issues"
    read_human_tasks(process_instance_id).each do |task|
      begin
        next if BpmIntegration::HumanTaskIssue.where(human_task_id:task.id).first
        task_definition = BpmIntegration::TaskDefinition.by_task_instance(
                                                            task.taskDefinitionKey, task.processDefinitionId).first
        issue = build_issue_from_task(task, task_definition)
        next if issue.nil?

        issue.human_task_issue = build_human_task_issue(task, task_definition)

        issue.custom_fields = custom_values_from_task_form_data(task, task_definition)

        if issue.save(validate: false)
          Delayed::Worker.logger.info "#{self.class} - Issue \##{issue.id} (" + issue.subject + ") criada baseada na human_task " + task.id
        else
          Delayed::Worker.logger.error "Ocorreram erros ao tentar salvar a issue " + issue.subject + "baseada na human_task " + task.id + ":"
          Delayed::Worker.logger.error issue.errors.messages.to_s
        end
      rescue => exception
        Delayed::Worker.logger.error exception.message
        exception.backtrace.each { |line| Delayed::Worker.logger.error line }
      end
    end
    Delayed::Worker.logger.info "#{self.class} - Sincronização de bpm_tasks concluída"
  rescue => e
    Delayed::Worker.logger.error l('error_bpm_tasks_job')
    Delayed::Worker.logger.error e.message
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
  end

  after_perform do |job|
    if job.arguments.empty?
      #JOB - Reagendamento
      self.class.set(wait: SyncJobsPeriod.bpm_task_period).perform_later
      Delayed::Worker.logger.info "#{self.class} - Sincronização de bpm_tasks agendada"
    end
  end

  private

  def read_human_tasks(process_instance_id)
    begin
      BpmTaskService.task_list(process_instance_id)
    rescue => e
      Delayed::Worker.logger.error e.to_s
      []
    end
  end

  def build_issue_from_task(task, task_definition)
    parent_id = Issue.by_process_instance(task.processInstanceId).pluck(:id).first
    if parent_id.nil?
      Delayed::Worker.logger.error "Não existe nenhuma issue para este processo"
      return nil
    end
    parent = Issue.find(parent_id)
    issue = Issue.new
    issue.status_id = task_definition.issue_status_id || Setting.plugin_bpm_integration[:new_status].to_i
    issue.subject = (task.name + " - " + parent.subject).truncate(255)
    issue.description = parent.description
    issue.priority_id = IssuePriority.default.id
    issue.author_id = Setting.plugin_bpm_integration[:bpm_user].to_i
    issue.tracker = get_tracker(task_definition)
    issue.parent_id = parent.id
    issue.assigned_to_id = get_assignee_id(task.assignee)
    issue.project_id = Project.where(identifier: task.formKey).pluck(:id).first || issue.parent.project_id

    issue.add_watcher(parent.author)

    issue
  end

  def get_tracker(task_definition)
    task_definition.tracker || task_definition.process_definition_version.process_definition.tracker
  end

  def get_assignee_id(task_assignee)
    Principal.where(id: task_assignee.to_i).pluck(:id).first
  end

  def build_human_task_issue(task, task_definition)
    human_task_issue = BpmIntegration::HumanTaskIssue.new
    human_task_issue.human_task_id = task.id
    human_task_issue.task_definition = task_definition

    human_task_issue
  end

  def custom_values_from_task_form_data(task, task_definition)
    custom_field_values = []
    form_fields_data = BpmTaskService.form_data(task.id)['formProperties']
    task_definition.form_fields.select { |ff| ff.readable }.each do |ff|
      ff_data = form_fields_data.select { |ffd| ffd["id"] == ff.field_id }.first
      custom_field_values << { id: ff.custom_field.id, value: (ff_data["value"] || '') }
    end

    custom_field_values
  end

end
