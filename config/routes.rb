# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :bpm_processes, only: [:index, :new, :create]

post "bpm_processes/upload" => "bpm_processes#upload", as: "upload_process"
get "bpm_processes/show/:process_id" => "bpm_processes#show", as: "show_process"
