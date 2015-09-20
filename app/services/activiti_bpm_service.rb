class ActivitiBpmService
  include HTTMultiParty
  format :json

  base_uri Setting.plugin_bpm_integration[:bpms_url]

  @@auth = {
    username: Setting.plugin_bpm_integration[:bpms_user],
    password: Setting.plugin_bpm_integration[:bpms_pass]
  }

end
