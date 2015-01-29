##################################
#
# CFME Automate Method: AWS_EBS_Snapshot_Create
#
# Notes: This method will snapshot a specified EBS Volume
#
# By: Brandon Johnson
#
# Requires the aws ruby sdk gem (gem aws-sdk)
# Dialogs Inputs: ebs_device (i.e. /dev/sdc) snapshot_description (i.e. database backup 09/04/2014)
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Snapshot_Create'
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


  ebs_device = $evm.root['dialog_ebs_device'].to_s
  snapshot_description = $evm.root['dialog_snapshot_description'].to_s


  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  ec2 = AWS.ec2 #=> AWS::Instance
  ec2.client #=> AWS::Instance::Client
  #log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  #log(:info, "Region: #{ec2.name}")


  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")



  attachedvolume = vm.custom_get("Attached_EBSVolume_#{ebs_device}")
  log(:info, "Creating a snapshot on volume: #{attachedvolume} that is attached to instance: #{instanceid}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  #snapshot the volume
  volume = ec2.volumes[attachedvolume]
  log(:info, "#{volume.exists?}")

  snapshot = volume.create_snapshot("#{snapshot_description}")
  sleep 1 until [:completed, :error].include?(snapshot.status)

  snapid = snapshot.id

  log(:info, "Snapshot created with id: #{snapid}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  #Add the snapshot id to a custom field
  log(:info, "Adding VM:<#{vm.name}> custom attribute:<:AWS_EBS_snapshot_ID_#{ebs_device}>_#{snapid} with Snapshot ID::#{snapid}>" )
  vm.custom_set("EBS_Snap_ID_#{ebs_device}_#{snapid}", snapid.to_s)
  vm.custom_set("EBS_SnapDescription_#{snapid}", snapshot_description.to_s)
  

  
  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

  # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
