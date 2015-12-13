class AddTimestamps < ActiveRecord::Migration
  def change
    add_timestamps(:bpmint_process_definitions, null: false)
    add_timestamps(:bpmint_tracker_proc_defs, null: false)
    add_timestamps(:bpmint_process_def_versions, null: false)
    add_timestamps(:bpmint_process_constants, null: false)
    add_timestamps(:bpmint_process_end_events, null: false)

    add_timestamps(:bpmint_form_field_definitions, null: false)

    add_timestamps(:bpmint_task_definitions, null: false)

    add_timestamps(:bpmint_human_task_issues, null: false)
    add_timestamps(:bpmint_issue_process_instances, null: false)
  end
end
