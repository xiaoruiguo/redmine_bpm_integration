class ActivitiBpmService
  include HTTMultiParty
  format :json

  base_uri Setting.plugin_bpm_integration[:bpms_url]

  @@auth = {
    username: Setting.plugin_bpm_integration[:bpms_user],
    password: Setting.plugin_bpm_integration[:bpms_pass]
  }

  def self.variables_from_hash(form)
    variables = []
    return [] if form.blank?
    form.each { |k, v| variables << { name: k, value: v } }
    variables
  end

end
