class BpmProcessInstancesController < ApplicationController
  unloadable

  before_filter :authorize_global

  def new
    @form_data = ActivitiBpmService.getFormData(params[:bpm_process_definition_id])['formProperties']
  end

  def create
    begin
      response = ActivitiBpmService.start_process(params[:bpm_process_definition_id], params[:form])
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
