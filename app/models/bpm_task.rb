class BpmTask
  include ActiveModel::AttributeMethods
  include HashInitialize

  attr_accessor :id, :name, :description, :assignee, :author, :status, :priority,
                :created_time, :due_date, :parent, :bpm_process, :definition_key

end
