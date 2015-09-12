# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :bpm_processes, only: [:index, :new, :create]

post "bpm_processes/start/:id" => "bpm_processes#start", as: "start_process"
post "bpm_processes/upload" => "bpm_processes#upload", as: "upload_process"
