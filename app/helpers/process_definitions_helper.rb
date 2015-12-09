# encoding: utf-8

module ProcessDefinitionsHelper

  def process_constants_component(form, constant)
    case constant.constant_type
    when 'status_id'
      select_tag("#{form.object_name}[#{constant.id}]", options_from_collection_for_select(
                                      IssueStatus.all, :id, :name,
                                      constant.value.to_i
          ),
          include_blank: true
        )
    when 'user_id'
      select_tag("#{form.object_name}[#{constant.id}]", options_from_collection_for_select(
                                      User.all, :id, :firstname,
                                      constant.value.to_i
          ),
          include_blank: true
        )
    when 'group_id'
      select_tag("#{form.object_name}[#{constant.id}]", options_from_collection_for_select(
                                      Group.all, :id, :lastname,
                                      constant.value.to_i
          ),
          include_blank: true
        )
    when 'project_id'
      select_tag("#{form.object_name}[#{constant.id}]", options_from_collection_for_select(
                                      Project.all, :id, :name,
                                      constant.value.to_i
          ),
          include_blank: true
        )
    else
      form.text_field :value, name: "#{form.object_name}[#{constant.id}]"
    end
  end

end
