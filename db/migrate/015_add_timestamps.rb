class AddTimestamps < ActiveRecord::Migration
  def change
    add_timestamps(:bpmint_process_definitions)
    change_column_null :bpmint_process_definitions, :created_at, false
    change_column_null :bpmint_process_definitions, :updated_at, false

    add_timestamps(:bpmint_tracker_proc_defs)
    change_column_null :bpmint_tracker_proc_defs, :created_at, false
    change_column_null :bpmint_tracker_proc_defs, :updated_at, false

    add_timestamps(:bpmint_process_def_versions)
    change_column_null :bpmint_process_def_versions, :created_at, false
    change_column_null :bpmint_process_def_versions, :updated_at, false

    add_timestamps(:bpmint_process_constants)
    change_column_null :bpmint_process_constants, :created_at, false
    change_column_null :bpmint_process_constants, :updated_at, false

    add_timestamps(:bpmint_process_end_events)
    change_column_null :bpmint_process_end_events, :created_at, false
    change_column_null :bpmint_process_end_events, :updated_at, false

    add_timestamps(:bpmint_form_field_definitions)
    change_column_null :bpmint_form_field_definitions, :created_at, false
    change_column_null :bpmint_form_field_definitions, :updated_at, false

    add_timestamps(:bpmint_task_definitions)
    change_column_null :bpmint_task_definitions, :created_at, false
    change_column_null :bpmint_task_definitions, :updated_at, false

    add_timestamps(:bpmint_human_task_issues)
    change_column_null :bpmint_human_task_issues, :created_at, false
    change_column_null :bpmint_human_task_issues, :updated_at, false

    add_timestamps(:bpmint_issue_process_instances)
    change_column_null :bpmint_issue_process_instances, :created_at, false
    change_column_null :bpmint_issue_process_instances, :updated_at, false

  end
end
