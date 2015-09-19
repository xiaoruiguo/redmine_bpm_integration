class BpmProcessInstancesController < BpmController

  def new
    @form_data = BpmProcessService.form_data(params[:bpm_process_definition_id])['formProperties']
  end

  def create
    begin
      response = BpmProcessService.start_process(params[:bpm_process_definition_id], params[:form])
      if !response.blank? && response.code == 201
        handle_sucess('msg_process_started')
      else
        handle_error('msg_process_start_error')
      end
    rescue
      handle_error('msg_process_start_error')
    end
  end

  def show
    process_image = BpmProcessService.process_instance_image params[:id]
    send_data process_image, :type => 'image/png', :disposition => 'inline'
  end

end
