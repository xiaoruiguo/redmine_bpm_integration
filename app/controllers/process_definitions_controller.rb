class ProcessDefinitionsController < BpmController
  layout 'admin'

  include Redmine::I18n

  before_filter :require_admin

  def index
    #JOB - Atualiza process_definitions
    SyncProcessDefinitionsJob.perform_now
    @process_definitions = BpmIntegration::ProcessDefinition.all
  end

  def edit
    @process_definition = BpmIntegration::ProcessDefinition.find(params[:id])
    @process_definition.tracker_process_definition ||= BpmIntegration::TrackerProcessDefinition.new
    @process_definition
  end

  def update
    @process_definition = BpmIntegration::ProcessDefinition.find(params.require(:id))
    @process_definition.update_attributes!(safe_params)

    flash[:notice] = t(:notice_successful_update)
    redirect_to action: :index
  end

  private

  def safe_params
    params.require(:bpm_integration_process_definition)
          .permit(:name, tracker_process_definition_attributes: [:id, :tracker_id])
  end

end
