###################################
#
# CFME Automate Method: Satellite5_GetActivationKeys
#
#
# Notes: This method gets a VM system id from Satellite v5
#
###################################
  begin
    # Method for logging
    def log(level, message)
      @method = 'Satellite5_GetActivationKeys'
      $evm.log(level, "#{@method}: #{message}")
    end

    log(:info, "CFME Automate Method Started")

    # Dump all root attributes
    log(:info, "Listing Root Object Attributes:")
    $evm.root.attributes.sort.each { |k, v| log(:info, "\t#{k}: #{v}") }
    log(:info, "===========================================")

    # Get Satellite server from model else set it here
    satellite = nil
    satellite ||= $evm.object['servername']

    # Get Satellite url from model else set it here
    satellite_url = "/rpc/api"
    satellite_url ||= $evm.object['serverurl']

    # Get Satellite username from model else set it here
    username = nil
    username ||= $evm.object['username']

    # Get Satellite password from model else set it here
    password = nil
    password ||= $evm.object.decrypt('password')

    # Require CFME rubygems and xmlrpc/client
    require "rubygems"
    require "xmlrpc/client"

    xmlrpc_client = XMLRPC::Client.new(satellite, satellite_url)
    log(:info, "xmlrpc_client: #{xmlrpc_client.inspect}")

    xmlrpc_key = xmlrpc_client.call('auth.login', username, password)
    log(:info, "xmlrpc_key: #{xmlrpc_key.inspect}")

    #ActivationKeys
    satellite_ActivationKeys = xmlrpc_client.call('activationkey.listActivationKeys', xmlrpc_key)
    log(:info, "satellite_ActivationKeys: #{satellite_ActivationKeys.inspect}")


    ak_hash = {}
    ak_hash[nil] = nil


    satellite_ActivationKeys.each do |ak|
      #log(:info, "Inspecting each key ---> #{ak.inspect}")
      log(:info, "trying to get Activation Keys from Spacewalk --> #{ak['key']}")
      ak_hash[ak['key']]= "#{ak['key']}" if ak['base_channel_label'] == "rhel-x86_64-server-6" and ak['disabled'] == false
    end


    $evm.object["sort_by"] = "description"
    $evm.object["sort_order"] = "ascending"
    $evm.object["data_type"] = "string"
    $evm.object["required"] = "true"
    $evm.object['values'] = ak_hash
    log(:info, "Dynamic drop down values: #{$evm.object['values']}")


    # Exit method
    log(:info, "CFME Automate Method Ended")
    exit MIQ_OK

    # Ruby rescue
  rescue => err
    log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
    exit MIQ_STOP
  end
