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

end
