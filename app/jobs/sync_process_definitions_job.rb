class SyncProcessDefinitionsJob < ActiveJob::Base
  queue_as :default

  def perform(process_definition_id = nil)
    if process_definition_id.blank?
      synchronize_process_list
    else
      synchronize_single_process(process_definition_id)
    end
  end

  protected

  def synchronize_process_list
    Delayed::Worker.logger.info "#{self.class} - Sincronizando process_definitions"
    BpmProcessDefinitionService.process_list.each do |process|
      next if BpmIntegration::ProcessDefinition.where(process_identifier:process.id).first
      begin
        Delayed::Worker.logger.info "#{self.class} - Sincronizando process_definition " + process.id.to_s
        save_process_definition(process)
      rescue => e
        Delayed::Worker.logger.error "#{self.class} - Ocorreu um erro ao realizar cadastro do processo " + process.id.to_s
        e.backtrace.each { |line| Delayed::Worker.logger.error line }
      end
    end
  rescue => e
    Delayed::Worker.logger.error "#{self.class} - Ocorreu um erro na sincronização."
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
  end

  def synchronize_single_process(deployment_id)
    Delayed::Worker.logger.info "#{self.class} - Sincronizando apenas process_definition - deploymentId: #{deployment_id}"
    process = BpmProcessDefinitionService.process_definition_by_deployment_id(deployment_id)
    save_process_definition(process)
  rescue => e
    Delayed::Worker.logger.error "#{self.class} - Ocorreu um erro ao realizar cadastro do processo - deploymentId: #{deployment_id}"
    e.backtrace.each { |line| Delayed::Worker.logger.error line }
  end

  def save_process_definition(process)
    new_process = build_process_definition(process)
    new_process.form_fields = synchronize_form_fields(new_process)
    synchronize_data_objects(new_process)
    new_process.task_definitions = synchronize_task_definitions(new_process)
    preset_previous_version_configurations(new_process)
    new_process.save!(validate:false)
    Delayed::Worker.logger.info "#{self.class} - Cadastro de definição do processo #{process.id.to_s} (#{new_process.version}) realizado com sucesso!"
  end

  def preset_previous_version_configurations(process)
    last_version = BpmIntegration::ProcessDefinition.where(key:process.key).where.not(id:process.id).order('version desc').first
    return if last_version.blank?

    preset_form_field_definitions(process, last_version)
    preset_process_tracker(process, last_version)
    preset_process_constants(process, last_version)
    preset_process_end_events(process, last_version)
  end

  def preset_process_tracker(process, last_version)
    process.tracker_process_definition = last_version.tracker_process_definition
  end

  def preset_form_field_definitions(process, last_version)
    process.form_field_definitions.each do |field|
      last_field = last_version.form_field_definitions.where(field_id:field.field_id).first
      next if last_field.blank?
      field.custom_field = last_field.custom_field
    end
  end

  def preset_process_constants(process, last_version)
    return unless process.constants

    process.constants.each do |constant|
      last_constant = last_version.constants.where(identifier:constant.identifier).first
      next if last_constant.blank? || last_constant.value.blank? || last_constant.constant_type != constant.constant_type
      constant.value = last_constant.value
    end
  end

  def preset_process_end_events(process, last_version)
    return unless process.end_events

    process.end_events.each do |end_event|
      last_end_event = last_version.end_events.where(identifier:end_event.identifier).first
      next if last_end_event.blank? || last_end_event.issue_status.blank?
      end_event.issue_status_id = last_end_event.issue_status_id
    end
  end

  #Synchronize constants and end_events from data_objects defined in Activiti
  def synchronize_data_objects(process)
    data_objects = BpmProcessDefinitionService.data_objects(process.process_identifier)
    process_constants = []
    process_end_events = []

    data_objects.map do |data_object|
      if data_object['value'] == "end_event"
        process_end_events << BpmIntegration::ProcessEndEvent.new(
          identifier: data_object['name'],
          name: data_object['id']
        )
      else
        process_constants << BpmIntegration::ProcessConstant.new(
                                    identifier: data_object['name'],
                                    name: data_object['id'],
                                    constant_type: data_object['value']
                                  )
      end
    end

    process.constants = process_constants
    process.end_events = process_end_events
  end

  def synchronize_form_fields(process)
    form_properties = BpmProcessDefinitionService.form_data(process.process_identifier)["formProperties"]

    form_fields = []
    form_properties.each do |form_item|
      next unless form_item["readable"]

      field_definition = find_or_create_form_field_definition(process, form_item)

      form_field = build_form_field_from_hash(form_item)

      form_field.form_field_definition = field_definition
      form_field.form_able = process

      form_fields << form_field
    end
    form_fields
  end

  def synchronize_task_definitions(process)
    tasks_properties = BpmTaskService.task_definitions(process.process_identifier)

    tasks = []
    tasks_properties.each do |t|
      task = BpmIntegration::TaskDefinition.new
      task.key = t["key"]

      task_form_properties = t["taskFormHandler"]["formPropertyHandlers"]

      form_fields = []
      task_form_properties.each do |form_item|
        next unless form_item["readable"]

        field_definition = find_or_create_form_field_definition(process, form_item)

        form_field = build_form_field_from_hash(form_item)
        form_field.form_field_definition = field_definition

        form_fields << form_field
      end
      task.form_fields = form_fields

      tasks << task
    end

    tasks
  end

  private

  def build_process_definition(bpm_process_definition)
    process = BpmIntegration::ProcessDefinition.new
    process.process_identifier = bpm_process_definition.id
    process.description = bpm_process_definition.description
    process.name = bpm_process_definition.name
    process.key = bpm_process_definition.key
    process.version = bpm_process_definition.version

    process
  end

  def find_or_create_form_field_definition(process, form_item_hash)
    BpmIntegration::FormFieldDefinition.process_field(process.process_identifier, form_item_hash["id"])
          .first_or_create do |ffd|
      ffd.process_definition = process
      ffd.name = form_item_hash["name"]
      ffd.field_type = form_item_hash["type"]["name"] if form_item_hash["type"]
    end
  end

  def build_form_field_from_hash(form_item_hash)
    form_field = BpmIntegration::FormField.new
    form_field.readable = form_item_hash["readable"]
    form_field.writable = form_item_hash["writable"]
    form_field.required = form_item_hash["required"]
    form_field.date_pattern = form_item_hash["datePattern"]

    form_field
  end

end
