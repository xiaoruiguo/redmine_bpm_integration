Rails.configuration.to_prepare do
  ActiveSupport::Dependencies
     .autoload_paths << File.expand_path('../app/services', __FILE__)
end

Redmine::Plugin.register :bpm_integration do
  name 'BPM Integration Plugin'
  author 'Filipe Xavier, Lucas Arnaud, Thales Pires'
  description 'This is a plugin for integrating Redmine with Activiti BPM.'
  version '0.0.1'
  url 'https://github.com/thalestpires/redmine_bpm_integration'

  menu :top_menu, :bpm_processes, { controller: 'bpm_process_definitions', action: 'index' } , caption: :bpm_processes

  settings default: {}, partial: 'settings/bpm_integration'
end
