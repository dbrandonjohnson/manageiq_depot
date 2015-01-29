##################################
#
# CFME Automate Method: AWS_EBS_Volume_Attach
#
# Notes: This method will attach an existing EBS Volume to an instance
#
# By: Brandon Johnson
#
# Requires the aws ruby sdk gem (gem aws-sdk)
# Dialogs Inputs: ebs_volume and ebs_device
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Volume_Attach'
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

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


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
  #log(:info, "Got AWS-SDK connection: #{ec2.inspect}")
  ec2.methods.sort.each {|method| log(:info, "METHOD: Instance.#{method}")}
  log(:info, "Region: #{ec2.name}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")



  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  volumeid = $evm.root['dialog_ebs_volume']
  ebs_device = $evm.root['dialog_ebs_device'].to_s

  log(:info, "attaching volume: #{volumeid} to #{ebs_device}")
  volume = ec2.volumes["#{volumeid}"]

  attachment = volume.attach_to(ec2.instances[instanceid], ebs_device)
  sleep 1 until attachment.status != :attaching

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  log(:info, "#{attachment.status}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  #Create a custom attribute in the VMDB database so we know the volume ID later for other methods
  log(:info, "Adding VM:<#{vm.name}> custom attribute:<:Attached_EBSVolume_#{ebs_device}> with Volume ID: #{volumeid}")
  vm.custom_set("Attached_EBSVolume_#{ebs_device}", volumeid.to_s)

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
