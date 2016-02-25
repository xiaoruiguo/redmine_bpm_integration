RAILS_ENV=$4 bin/delayed_job stop
mysql -u $1 -p$2 $3 -e "DELETE FROM delayed_jobs where queue = 'bpm_process_instances' or queue = 'bpm_tasks';"
