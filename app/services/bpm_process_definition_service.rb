class BpmProcessDefinitionService < ActivitiBpmService

  def self.process_definition(id)
    process = get(
      "/repository/process-definitions/#{id}",
      query: { latest: true },
      basic_auth: @@auth
    )

    BpmProcessDefinition.new(process)
  end

  def self.process_definition_by_deployment_id(deployment_id)
    process = get(
      "/repository/process-definitions",
      query: { deploymentId: deployment_id },
      basic_auth: @@auth
    )["data"].first
    BpmProcessDefinition.new(process)
  end

  def self.process_list
    processes = []
    process_list = get(
      '/repository/process-definitions',
      query: { latest: true },
      basic_auth: @@auth
    )["data"]
    process_list.each do |p|
      processes << BpmProcessDefinition.new(p)
    end
    return processes
  rescue => e
    puts "Ocorreu um erro ao acessar a url " + base_uri
    puts e
    raise "Ocorreu um erro inesperado. Entre em contato com o suporte."
  end

  def self.process_image(process_id)
    get(
      '/repository/process-definitions/' + process_id + '/image',
      basic_auth: @@auth
    ).body
  end

  def self.form_data(processId)
    get(
      '/form/form-data',
      basic_auth: @@auth,
      query: { processDefinitionId: processId },
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def self.deploy_process(process_data)
    post(
      '/repository/deployments',
      basic_auth: @@auth,
      multipart: true,
      query: {
        file: process_data
      }
    )
  end

  def self.data_objects(process_id)
    get(
      "/repository/process-definitions/#{process_id}/model",
      basic_auth: @@auth
    )["mainProcess"]["dataObjects"]
  end

end
