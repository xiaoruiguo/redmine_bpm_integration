class ProcessDefinitionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def index
    @process_definitions = BpmIntegration::ProcessDefinition.all
  end

  def edit
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    @process_definition.tracker_process_definition = BpmIntegration::TrackerProcessDefinition.find(@process_definition.tracker_process_definition_id) unless @process_definition.tracker_process_definition_id.blank?
    @process_definition
  end

  def update
    @process_definition = BpmIntegration::ProcessDefinition.find(params.require(:id))
    if @process_definition.tracker_process_definition_id.blank?
      @process_definition.tracker_process_definition ||= BpmIntegration::TrackerProcessDefinition.new
      @process_definition.tracker_process_definition.process_definition_key ||= @process_definition.key
    end
    @process_definition.tracker_process_definition.update_attributes(
      params.require(:bpm_integration_process_definition).require(:tracker_process_definition).permit(:tracker_id)
    )
    # @process_definition.save!
    # @process_definition.tracker_process_definition.save!

    flash[:notice] = t(:notice_successful_update)
    redirect_to action: :edit
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = BpmProcessDefinitionService.deploy_process(process_data)
      if !response.blank? && response.code == 201
        handle_sucess('msg_process_uploaded')
        SynchronizeProcessDefinitionsJob.perform_now
      else
        handle_error('msg_process_upload_error')
      end
    rescue
      handle_error('msg_process_upload_error')
    end
  end

  def show
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    process_image = BpmProcessDefinitionService.process_image @process_definition.process_identifier
    send_data process_image, :type => 'image/png',:disposition => 'inline'
  end

end
