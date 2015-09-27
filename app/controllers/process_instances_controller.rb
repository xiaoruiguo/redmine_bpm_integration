class ProcessInstancesController < BpmController

  def show
    issue = Issue.find(params[:id])

    if issue.process_instance.blank?
      render_404
      return
    end

    process_image = BpmProcessInstanceService.process_instance_image issue.process_instance.process_instance_id.to_s
    send_data process_image, :type => 'image/png', :disposition => 'inline'
  end

end
