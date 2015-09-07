Redmine::Plugin.register :bpm_integration do
  name 'BPM Integration Plugin'
  author 'Filipe Xavier, Lucas Arnaud, Thales Pires'
  description 'This is a plugin for integrating Redmine with any BPMS like Activiti and Bonita.'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :top_menu  , :bpm_processes, { controller: 'bpm_processes', action: 'index' } , caption: :bpm_processes

  settings default: {}, partial: 'settings/bpm_integration'

end
