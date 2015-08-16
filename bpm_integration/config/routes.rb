# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :bpm_processes, only: [:index]
resources :bpm_tasks, only: [:index]

post "bpm_processes/start/:id" => "bpm_processes#start", as: "start_process"
