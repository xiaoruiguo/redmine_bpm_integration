class BpmProcessDefinitionsController < ApplicationController
  unloadable

  before_filter :authorize_global

  def show
    process_image = ActivitiBpmService.process_image params[:id]
    send_data process_image, :type => 'image/png',:disposition => 'inline'
  end

  def index
    @process_list = ActivitiBpmService.process_list
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = ActivitiBpmService.deploy_process(process_data)
      if !response.blank? && response.code == 201
        Tracker.first_or_initialize
        handle_sucess('msg_process_uploaded')
      else
        handle_error('msg_process_upload_error')
      end
    rescue
      handle_error('msg_process_upload_error')
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
