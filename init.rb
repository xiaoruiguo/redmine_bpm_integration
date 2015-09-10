Redmine::Plugin.register :bpm_integration do
  name 'BPM Integration Plugin'
  author 'Filipe Xavier, Lucas Arnaud, Thales Pires'
  description 'This is a plugin for integrating Redmine with Activiti BPM.'
  version '0.0.1'
  url 'https://github.com/thalestpires/redmine_bpm_integration'

  menu :top_menu  , :bpm_processes, { controller: 'bpm_processes', action: 'index' } , caption: :bpm_processes

  settings default: {}, partial: 'settings/bpm_integration'

end
