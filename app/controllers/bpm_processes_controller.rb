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

  def upload
    begin
      process_data = params[:upload].tempfile
      response = Httparty.new.deploy_process(process_data)
      if !response.blank? && response.code == 201
        handle_sucess('msg_process_uploaded')
      else
        handle_error('msg_process_upload_error')
      end
    rescue
      handle_error('msg_process_upload_error')
    end
  end

  def create
    begin
      response = Httparty.new.start_process(params[:id], params[:form])
      if !response.blank? && response.code == 201
        handle_sucess('msg_process_started')
      else
        handle_error('msg_process_start_error')
      end
    rescue
      handle_error('msg_process_start_error')
    end
  end

  def handle_sucess(msg_code)
    redirect_to :back, notice: l(msg_code)
  end

  def handle_error(msg_code)
    logger.error response.code
    logger.error response.body
    redirect_to :back, alert: l(msg_code)
  end

end
