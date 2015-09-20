# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :bpm_process_definitions, only: [:index, :create, :show, :new] do
  resources :bpm_process_instances, only: [:new, :create]
end

resources :bpm_process_instances, only: [:show]

match 'bpm_task_instances/sync', controller: 'bpm_task_instances', action: 'sync', via: 'get'
