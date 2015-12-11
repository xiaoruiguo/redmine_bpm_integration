# encoding: utf-8

module ProcessDefinitionVersionsHelper

  def process_constants_component(form, constant)
    case constant.constant_type
    when 'status_id'
      form.collection_select(:value, IssueStatus.all, :id, :name, include_blank: true)
    when 'user_id'
      form.collection_select(:value, User.all, :id, :firstname, include_blank: true)
    when 'group_id'
      form.collection_select(:value, Group.all, :id, :lastname, include_blank: true)
    when 'project_id'
      form.collection_select(:value, Project.all, :id, :name, include_blank: true)
    else
      form.text_field :value
    end
  end

end
