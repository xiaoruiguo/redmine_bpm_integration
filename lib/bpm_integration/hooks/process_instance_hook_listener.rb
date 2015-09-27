class ProcessInstanceHookListener < Redmine::Hook::ViewListener

	render_on :view_issues_show_details_bottom, :partial => 'process_instances/process_instance_image_link'

end
