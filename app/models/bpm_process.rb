class BpmProcess
  include ActiveModel::AttributeMethods
  include HashInitialize

  attr_accessor :id, :name, :version
  
end
