# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :process_definitions, except: [:destroy] do
  # resources :bpm_process_instances, only: [:show]
end

resources :bpm_process_instances, only: [:show]

match 'bpm_task_instances/sync', controller: 'bpm_task_instances', action: 'sync', via: 'get'
