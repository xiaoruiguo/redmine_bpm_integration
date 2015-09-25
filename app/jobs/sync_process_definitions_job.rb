class SyncProcessDefinitionsJob < ActiveJob::Base
  queue_as :default

  def perform
    synchronize
  end

  protected

  def synchronize
    BpmProcessDefinitionService.process_list.each do |process|
      next if BpmIntegration::ProcessDefinition.where(process_identifier:process.id).first
      new_process = BpmIntegration::ProcessDefinition.new
      new_process.process_identifier = process.id
      new_process.description = process.description
      new_process.name = process.name
      new_process.key = process.key
      new_process.version = process.version

      new_process.form_fields = synchronize_form_fields(new_process)

      new_process.task_definitions = synchronize_task_definitions(new_process)

      if new_process.save!(validate:false)
        p 'Processo ' + new_process.id.to_s + ' salvo com sucesso!'
      else
        p 'Ocorreu um erro ao salvar o processo ' + new_process.id.to_s
      end
    end
  end

  def synchronize_form_fields(process)
    form_properties = BpmProcessDefinitionService.form_data(process.process_identifier)["formProperties"]

    form_fields = []
    form_properties.each do |form_item|
      field_definition = BpmIntegration::FormFieldDefinition.process_field(process.process_identifier, form_item["id"])
                          .first_or_create do |ffd|
        ffd.process_definition = process
        ffd.name = form_item["name"]
        ffd.field_type = form_item["type"]
      end

      form_field = BpmIntegration::FormField.new
      form_field.readable = form_item["readable"]
      form_field.writable = form_item["writable"]
      form_field.required = form_item["required"]
      form_field.date_pattern = form_item["datePattern"]

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
        field_definition = BpmIntegration::FormFieldDefinition.process_field(process.process_identifier, form_item["id"])
                            .first_or_create do |ffd|
          ffd.process_definition = process
          ffd.name = form_item["name"]
          ffd.field_type = form_item["type"]
        end

        form_field = BpmIntegration::FormField.new
        form_field.readable = form_item["readable"]
        form_field.writable = form_item["writable"]
        form_field.required = form_item["required"]
        form_field.date_pattern = form_item["datePattern"]

        form_field.form_field_definition = field_definition

        form_fields << form_field
      end
      task.form_fields = form_fields

      tasks << task
    end

    tasks
  end

end
