class SynchronizeProcessDefinitionsJob < ActiveJob::Base
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

      form_properties = BpmProcessDefinitionService.form_data(process.id)["formProperties"]

      form_fields = []
      form_properties.each do |form_item|
        form_field = BpmIntegration::ProcessFormField.new
        form_field.field_id =form_item["id"]
        form_field.name =form_item["name"]
        form_field.field_type = form_item["type"]
        form_field.readable = form_item["readable"]
        form_field.writable = form_item["writable"]
        form_field.required = form_item["required"]
        form_field.date_pattern = form_item["datePattern"]

        form_fields << form_field
      end
      new_process.form_fields = form_fields

      if new_process.save!(validate:false)
        p 'Processo ' + new_process.id.to_s + ' salvo com sucesso!'
      else
        p 'Ocorreu um erro ao salvar o processo ' + new_process.id.to_s
      end
    end
  end

end
