bin/delayed_job --pool=bpm_tasks:1 --pool=bpm_process_instances:1 start

rake redmine:plugins:bpm_integration:sync_bpm_tasks
rake redmine:plugins:bpm_integration:sync_process_instances
