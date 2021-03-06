class ProcessInstancesController < BpmController
  skip_before_filter :authorize_global

  def show
    issue = Issue.find(params[:id])

    if issue.process_instance.blank?
      render_404
      return
    end

    respond_to do |format|
      format.png do
	    process_image = BpmProcessInstanceService.process_instance_image issue.process_instance
	    send_data process_image, :type => 'image/png', :disposition => 'inline'
      end
    end

  end

end
