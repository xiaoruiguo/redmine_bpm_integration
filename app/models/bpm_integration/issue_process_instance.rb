class BpmIntegration::IssueProcessInstance < BpmIntegrationBaseModel

  belongs_to :issue
  belongs_to :process_definition_version


  def update_issue_status_on_close_for_end_event(endActivityId)
    end_event = process_definition_version.end_event_for(endActivityId)

    issue.init_journal(User.find(Setting.plugin_bpm_integration[:bpm_user]))

    if end_event.present?
      issue.status_id = end_event.issue_status_id
      issue.current_journal.notes = end_event.notes
      issue.save!(validate:false)
    else
      issue.status_id = Setting.plugin_bpm_integration[:closed_status].to_i
    end

    issue.save!(validate:false)
  end

end
