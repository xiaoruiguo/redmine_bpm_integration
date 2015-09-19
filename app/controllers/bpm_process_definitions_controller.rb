class BpmProcessDefinitionsController < BpmController

  def index
    @process_list = BpmProcessService.process_list
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = BpmProcessService.deploy_process(process_data)
      if !response.blank? && response.code == 201
        handle_sucess('msg_process_uploaded')
      else
        handle_error('msg_process_upload_error')
      end
    rescue
      handle_error('msg_process_upload_error')
    end
  end

  def show
    process_image = BpmProcessService.process_image params[:id]
    send_data process_image, :type => 'image/png',:disposition => 'inline'
  end

end
