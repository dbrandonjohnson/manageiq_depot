###################################
#
# CFME Automate Method: Satellite5_CheckforUpdates
#
# by Keivn Morey
#
# Notes: This method removes a VM from Satellite
# - Gem requirements: xmlrpc/client
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'Satellite5_RemoveSystem'
    $evm.log(level, "#{@method}: #{message}")
  end

  # Remove vm from Satellite
  def check_updates(vm, satellite, satellite_url, username, password)
    # Require CFME rubygems and xmlrpc/client
    require "rubygems"
    require "xmlrpc/client"

    xmlrpc_client = XMLRPC::Client.new(satellite, satellite_url)
    log(:info, "xmlrpc_client: #{xmlrpc_client.inspect}")

    xmlrpc_key = xmlrpc_client.call('auth.login', username, password)
    log(:info, "xmlrpc_key: #{xmlrpc_key.inspect}")

    # Get the system id from Satellite
    satellite_systemid = xmlrpc_client.call('system.getId', xmlrpc_key, vm.name)
    raise "VM:<#{vm.name}> not found on Satellite:<#{satellite}>" if satellite_systemid.nil?
    log(:info, "satellite_systemid: #{satellite_systemid.inspect}")

    vm_systemid = satellite_systemid[0]["id"]
    log(:info, "VM:<#{vm.name}> with systemid:<#{vm_systemid.inspect}> found on Satellite:<#{satellite}>")

    # checking system for updates Satellite
    log(:info, "Checking VM <#{vm.name}> for updates with SystemID:<#{vm_systemid}> on Satellite:<#{satellite}>")
    xmlrpc_client.call('system.checkupdate', xmlrpc_key, vm_systemid)
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
  satellite_url = nil
  satellite_url ||= $evm.object['serverurl']

  # Get Satellite username from model else set it here
  username = nil
  username ||= $evm.object['username']

  # Get Satellite password from model else set it here
  password = nil
  password ||= $evm.object.decrypt('password')

  # Get vm object from the VM class versus the VmOrTemplate class
  vm = $evm.vmdb("vm", $evm.root['vm_id'])
  raise "$evm.root['vm'] not found" if vm.nil?
  log(:info, "Found VM:<#{vm.name}>")
  check_updates(vm, satellite, satellite_url, username, password)

  #Apply Update Tag
  vm.tag_assign("SpaceWalkUpdatesAvailable/#{shortname}")

  #Apply custom attribute (last_update_check)
  m.custom_set(:Satellite_Last_Update_Check, timestamp)

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

  # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end
