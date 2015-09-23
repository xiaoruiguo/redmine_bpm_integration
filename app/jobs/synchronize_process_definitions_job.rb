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
      if new_process.save!(validate:false)
        p 'Processo ' + new_process.id.to_s + ' salvo com sucesso!'
      else
        p 'Ocorreu um erro ao salvar o processo ' + new_process.id.to_s
      end
    end
  end

end
