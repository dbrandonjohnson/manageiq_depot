###################################
#
# CFME Automate Method: AWS_EBS_Volume_DetachDelete
#
# By: Brandon Johnson
#
# Notes: This method will detach a specific volume from an Instance instance and delete it
#
# Dialogs Inputs: ebs_device (i.e. /dev/sdc)
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Volume_DetachDelete'
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

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")


  ebs_device = $evm.root['dialog_ebs_device'].to_s


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


  #attachedvolumes = ec2.instances[instanceid].block_devices

  #log(:info, "#{attachedvolumes}")


  instancezone = ec2.instances[instanceid].availability_zone
  log(:info, "Getting Instance Info #{instancezone}")

  attachedvolume = vm.custom_get("Attached_EBSVolume_#{ebs_device}")

  log(:info, "#{attachedvolume}")


  volume = ec2.volumes[attachedvolume]
  log(:info, "#{volume.exists?}")


  volume.attachments.each do |attachment|
    attachment.delete(:force => false)
  end

  sleep 1 until volume.status == :available
  volume.delete

  vm.custom_set("Attached_EBSVolume_#{ebs_device}", nil)



  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue
  rescue => err
    log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
    exit MIQ_ABORT
  end
