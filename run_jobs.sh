RAILS_ENV=$1 bin/delayed_job --pool=bpm_tasks:1 --pool=bpm_process_instances:1 start

RAILS_ENV=$1 rake redmine:plugins:bpm_integration:sync_bpm_tasks
RAILS_ENV=$1 rake redmine:plugins:bpm_integration:sync_process_instances
RAILS_ENV=$1 rake redmine:plugins:bpm_integration:start_process
