class BpmProcessInstancesController < BpmController

  def show
    process_image = BpmProcessInstanceService.process_instance_image params[:id]
    send_data process_image, :type => 'image/png', :disposition => 'inline'
  end

end
