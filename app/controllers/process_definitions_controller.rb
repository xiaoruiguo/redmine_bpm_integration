class ProcessDefinitionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def index
    #JOB - Atualiza process_definitions
    SyncProcessDefinitionsJob.perform_now
    @process_definitions = BpmIntegration::ProcessDefinition.latest
  end

  def edit
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    @process_definition.tracker_process_definition = BpmIntegration::TrackerProcessDefinition.find(@process_definition.tracker_process_definition_id) unless @process_definition.tracker_process_definition_id.blank?
    @process_definition
  end

  def update
    @process_definition = BpmIntegration::ProcessDefinition.find(params.require(:id))
    if @process_definition.tracker_process_definition_id.blank?
      @process_definition.tracker_process_definition ||= BpmIntegration::TrackerProcessDefinition.where(process_definition_key: @process_definition.key).first_or_initialize
    end
    @process_definition.tracker_process_definition.update_attributes(
      params.require(:bpm_integration_process_definition).require(:tracker_process_definition).permit(:tracker_id)
    )

    @process_definition.form_field_definitions.each do |ffd|
      ffd.custom_field_id = params[:bpm_integration_process_definition][:form_field_definitions][ffd.id.to_s]
    end

    @process_definition.constants.each do |const|
      const.value = params[:bpm_integration_process_definition][:constants][const.id.to_s]
    end

    @process_definition.save!

    flash[:notice] = t(:notice_successful_update)
    redirect_to action: :index
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = BpmProcessDefinitionService.deploy_process(process_data)
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
  end

  def show
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])

    respond_to do |format|
      format.png do
        process_image = BpmProcessDefinitionService.process_image @process_definition.process_identifier
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
