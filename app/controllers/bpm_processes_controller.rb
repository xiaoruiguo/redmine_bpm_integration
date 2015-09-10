class BpmProcessesController < ApplicationController
  unloadable

  def index
    @process_list = Httparty.new.process_list
  end

  def new
    id = params[:processId]
    @process = BpmProcess.new id: id
    @form_data = Httparty.new.getFormData(id)['formProperties']
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
