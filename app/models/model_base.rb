class ModelBase
  include ActiveModel::AttributeMethods

  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def initialize(*h)
    if h.length == 1 && h.first.kind_of?(Hash)
      hash = h.first.select { |key, value| attributes.map{ |attr| attr.to_s }.include?(key) }
      hash.each { |k,v| send("#{k}=",v) }
    end
  end

end
