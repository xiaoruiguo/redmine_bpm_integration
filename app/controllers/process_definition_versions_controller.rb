class ProcessDefinitionVersionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def edit
    @process_definition_version = BpmIntegration::ProcessDefinitionVersion.find(params[:id])
    @process_definition_version
  end

  def update
    @process_definition_version = BpmIntegration::ProcessDefinitionVersion.find(params.require(:id))
    @process_definition_version.update_attributes!(safe_params)

    flash[:notice] = t(:notice_successful_update)
    redirect_to edit_bpm_integration_process_definition_path(@process_definition_version.process_definition)
  end

  def safe_params
    params.require(:bpm_integration_process_definition_version)
          .permit(:active, :name, form_field_definitions_attributes: [:id, :custom_field_id],
          constants_attributes: [:id, :value],
          end_events_attributes: [:id, :issue_status_id])
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = BpmProcessDefinitionService.deploy_process(process_data)
      begin
        if !response.blank? && response.code == 201
        #JOB - Atualiza process_definitions (specific)
        SyncProcessDefinitionsJob.perform_now(response["id"])
        handle_sucess('msg_process_uploaded')
        else
          handle_error(l('msg_process_upload_error'), nil, response, true)
        end
      rescue => error
        handle_error(l('msg_process_upload_error'), error)
      end
    rescue => error
      handle_error(l('msg_process_upload_error'), error, nil, true)
    end
  end

  def show
    @process_definition_version = BpmIntegration::ProcessDefinitionVersion.find(params[:id])

    respond_to do |format|
      format.png do
        process_image = BpmProcessDefinitionService.process_image @process_definition_version.process_identifier
        send_data process_image, :type => 'image/png',:disposition => 'inline'
      end
    end

  end

  def handle_sucess(msg_code)
    redirect_to :back, notice: l(msg_code)
  end

  def handle_error(msg_code, error = nil, response = nil, print_error = false)
    logger.error self.class
    if response
      print_msg = msg_code.to_s + " - " + response.message.to_s + " - " + response.code.to_s + " - " + response["exception"].to_s
      logger.error response.code
      logger.error response.message
      logger.error response["exception"]
    end

    if error
      print_msg = msg_code.to_s + " " + error.message.to_s
      logger.error error.message
      error.backtrace.each { |line| logger.error line }
    end

    if print_error == true
      msg_code = print_msg
    end

    redirect_to :back, flash: {error: msg_code }
  end

end
