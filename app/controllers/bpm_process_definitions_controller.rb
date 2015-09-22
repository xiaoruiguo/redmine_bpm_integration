class BpmProcessDefinitionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def index
    @process_list = BpmProcessDefinitionService.process_list
  end

  def edit
    @process_definition = BpmProcessDefinitionService.process_definition(params[:id])
    @tracker_process_relation = BpmIntegration::TrackerProcessDefinition
                                  .where(process_definition_key: params[:id])
                                  .first_or_initialize
  end

  def update
    @process_definition = BpmProcessDefinitionService.process_definition(params[:id])
    @tracker_process_relation = BpmIntegration::TrackerProcessDefinition
                                  .where(process_definition_key: params[:id])
                                  .first_or_initialize
    @tracker_process_relation.tracker_id = params[:tracker]
    @tracker_process_relation.save

    flash[:notice] = t(:notice_successful_update)
    redirect_to action: :edit
  end

  def create
    begin
      process_data = params[:bpm_process_definition][:upload].tempfile
      response = BpmProcessDefinitionService.deploy_process(process_data)
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
    process_image = BpmProcessDefinitionService.process_image params[:id]
    send_data process_image, :type => 'image/png',:disposition => 'inline'
  end

end
