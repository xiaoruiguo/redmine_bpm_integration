# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :process_definitions, except: [:destroy], as: :bpm_integration_process_definitions
resources :process_definition_versions, except: [:destroy], as: :bpm_integration_process_definition_versions
resources :process_instances, only: [:show]

match 'bpm_task_instances/sync', controller: 'bpm_task_instances', action: 'sync', via: 'get'
