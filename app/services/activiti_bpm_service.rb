class ActivitiBpmService
  include HTTMultiParty
  format :json

  base_uri Setting.plugin_bpm_integration[:bpms_url]

  @@auth = {
    username: Setting.plugin_bpm_integration[:bpms_user],
    password: Setting.plugin_bpm_integration[:bpms_pass]
  }

  def self.variables_from_hash(form)
    return [] if form.blank?
    form.map { |k, v|
      { name: k, value: (v.is_a?(Array) ? v.to_json : v) }
    }.reduce([], &:<<)
  end

  def self.default_fields_form_values(issue)
    {
      "status_id" => issue.status_id,
      "user_id" => User.current.try(&:id),
      "created_on" => issue.created_on.in_time_zone('Brasilia'),
      "closed_on" => issue.closed_on,
      "user_mail" => User.current.try(&:mail),
      "user_firstname" => User.current.try(&:firstname),
      "user_lastname" => User.current.try(&:lastname)
    }
  end

  def self.query_parameters_from_hash(params)
    params.compact.map { |k, v| "#{k}=#{v}" }.join('&')
  end
end
