class BpmIntegration::FormField < BpmIntegrationBaseModel

  belongs_to :form_able, polymorphic: true, touch: true
  belongs_to :form_field_definition
  has_one :custom_field, through: :form_field_definition

  def field_id
    self.form_field_definition.field_id
  end

end
