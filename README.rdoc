= Redmine BPM Integration

[![Code Climate](https://codeclimate.com/github/thalestpires/redmine_bpm_integration/badges/gpa.svg)](https://codeclimate.com/github/thalestpires/redmine_bpm_integration)

This is a plugin for integrating Redmine with Activiti BPM.

Check the 'Activiti BPM Webapp Example' to test this redmine plugin (https://github.com/thalestpires/activiti_bpm_example/).

The Active Record backend requires a jobs table. You can create that table by running the following command:

  rails generate delayed_job:active_record
  rake db:migrate
