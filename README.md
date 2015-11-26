## Redmine BPM Integration

[![Stories in Ready](https://badge.waffle.io/thalestpires/redmine_bpm_integration.svg?label=ready&title=Ready)](http://waffle.io/thalestpires/redmine_bpm_integration)
[![Code Climate](https://codeclimate.com/github/thalestpires/redmine_bpm_integration/badges/gpa.svg)](https://codeclimate.com/github/thalestpires/redmine_bpm_integration) [![Dependency Status](https://gemnasium.com/thalestpires/redmine_bpm_integration.svg)](https://gemnasium.com/thalestpires/redmine_bpm_integration)

This is a plugin for integrating Redmine with Activiti BPM.

Check the 'Activiti BPM Webapp Example' to test this redmine plugin (https://github.com/thalestpires/activiti_bpm_example/).

The Active Record backend requires a jobs table. You can create that table by running the following command:

  rails generate delayed_job:active_record
  rake db:migrate

  Installation of the delayed_job gem (using active record):
    - Run the commands below:
    RAILS_ENV=production bundle exec rails generate delayed_job:active_record
    RAILS_ENV=production rake db:migrate

    - Create the config file with the following lines:

      #config/initializers/delayed_job_config.rb

      Delayed::Worker.destroy_failed_jobs = false
      Delayed::Worker.sleep_delay = 60
      Delayed::Worker.max_attempts = 3
      Delayed::Worker.max_run_time = 5.minutes
      Delayed::Worker.read_ahead = 10
      Delayed::Worker.default_queue_name = 'default'
      Delayed::Worker.delay_jobs = !Rails.env.test?
      Delayed::Worker.raise_signal_exceptions = :term
      Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
      Delayed::Worker.logger.datetime_format = '%Y-%m-%d %H:%M:%S'
      
    - Give write permission to the log file
      >chmod a+w {RAILS_ROOT_PATH}/log/delayed_job.log

    - To start/stop or check the status of the delayed_job run:
      >RAILS_ENV=development script/delayed_job -n 2 start #where 2 is the number of workers
      OR, to execute and follow:
      > rake jobs:work

      * You can also run stop & status

    - To stop all jobs running run:
      >rake jobs:clear

    - In development an error occurs when delayed job runs a job scheduled by itself. To prevent this error add the following line to {RAILS_ROOT_PATH}/config/environments/{Rails.env}.rb :
      >config.cache_classes = true
