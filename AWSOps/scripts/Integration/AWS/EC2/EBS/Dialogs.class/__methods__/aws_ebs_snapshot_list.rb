##################################
#
# CFME Automate Method: AWS_EBS_Snapshot_List
#
# Notes: This method will List all available EBS Snapshots
#
# By: Brandon Johnson
#
# Requires the aws ruby sdk gem (gem aws-sdk)
# Inputs:
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Snapshot_List'
    $evm.log(level, "#{@method} - #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root

  require 'rubygems'
  require 'aws-sdk-v1'


  vm = $evm.root['vm']
  aws = vm.ext_management_system
  log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  #aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  log(:info, "AWS: #{aws.authentication_userid}")
  log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "AWS: Region: #{aws.provider_region}")

  AWS.config(
      :access_key_id => aws.authentication_userid,
      :secret_access_key => aws.authentication_password
  )



  instanceid = vm.ems_ref
  log(:info, "Instance ID:  #{instanceid}")

  ec2 = AWS::EC2.new().regions[aws.provider_region]
  log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  log(:info, "Region: #{ec2.name}")
  #log(:info, "#{ec2.snapshots.inject({}) { |m, s| m[s.id] = s.status; m }}")
  #ec2.snapshots.with_owner("self")

  #log(:info, "snapshots -> #{ec2.snapshots.with_owner("self").id}")

  snap_hash = {}
  snap_hash[nil] = nil
  #
  for snapshot in ec2.snapshots.with_owner("self")
    log(:info, "#{snapshot.id} #{snapshot.status} #{snapshot.volume_id}")
  #  log(:info, "#{aws.hostname} -> #{snapshot.id}")
     snap_hash[snapshot.id] = "#{snapshot.id}" if snapshot.status == :completed and vm.custom_get("Attached_EBSVolume_/dev/sdd") == snapshot.volume.id
  end
  log(:info, "#{snap_hash}")


  $evm.object["sort_by"] = "description"
  $evm.object["sort_order"] = "ascending"
  $evm.object["data_type"] = "string"
  $evm.object["required"] = "true"
  $evm.object['values'] = snap_hash
  log(:info, "Dynamic drop down values: #{$evm.object['values']}")



  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
