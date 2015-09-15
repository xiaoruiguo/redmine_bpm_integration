class BpmTask < ModelBase
  attr_accessor :id, :name, :description, :assignee, :owner, :author, :status, :priority,
                :createTime, :dueDate, :parent, :processDefinitionId, :taskDefinitionKey,
                :category, :formKey
end
