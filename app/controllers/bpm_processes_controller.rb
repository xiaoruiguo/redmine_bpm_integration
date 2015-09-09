class BpmProcessesController < ApplicationController
  unloadable

  def index
    @process_list = Httparty.new.process_list
  end

  def new
    id = params[:processId]
    @process = BpmProcess.new id: id
    @form_data = Httparty.new.getFormData(id)['formProperties']
    # @form_data = JSON.parse('{"formKey":null,"deploymentId":"1","processDefinitionId":"solicitacaoDeFerias:1:4","processDefinitionUrl":"http://localhost:18080/bpm/service/repository/process-definitions/solicitacaoDeFerias:1:4","taskId":null,"taskUrl":null,"formProperties":[{"id":"qtd_dias_ferias","name":"Quantidade de dias","type":"long","value":null,"readable":true,"writable":true,"required":true,"datePattern":null,"enumValues":[]},{"id":"dt_inicio_ferias","name":"InÃ­cio das fÃ©rias","type":"date","value":null,"readable":true,"writable":true,"required":true,"datePattern":"dd/MM/yyyy","enumValues":[]}]}')['formProperties']
  end

  def create
    begin
      response = Httparty.new.start_process(params[:id], params[:form])
      if !response.blank? && response.code == 201
        redirect_to :back, notice: l('msg_process_started')
      else
        logger.error response.code
        logger.error response.body
        redirect_to :back, alert: l('msg_process_start_error')
      end
    rescue
      logger.error(response.code)
      logger.error response.body
      redirect_to :back, alert: l('msg_process_start_error')
    end
  end

end
