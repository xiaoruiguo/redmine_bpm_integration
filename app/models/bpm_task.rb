class BpmTask < ModelBase
  attr_accessor :id, :name, :description, :assignee, :owner, :status, :priority,
                :createTime, :dueDate, :parent, :processDefinitionId, :taskDefinitionKey,
                :category, :formKey, :processInstanceId
end
