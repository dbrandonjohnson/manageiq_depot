##################################
#
# CFME Automate Method: AWS_EBS_Volume_CreateAttach
#
# Notes: This method will create an EBS Volume and attach it to a selected instance
#
# By: Brandon Johnson
#
# Requires the aws ruby sdk gem (gem aws-sdk)
# Dialogs Inputs: ebs_size and ebs_device
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_EBS_Volume_CreateAttach'
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


  case $evm.root['vmdb_object_type']
    when 'miq_provision'
      vm = prov.vm

      dialog_ebs_size_hash = Hash[$evm.root.attributes.sort.collect { |k, v| [k, v] if k.starts_with?('ebs_size') }]
      ebs = []
      dialog_ebs_size_hash.each {|k,v| ebs << v.to_i if k.to_s =~ /ebs_size(\d*)/}
    when 'vm'
      vm = $evm.root['vm']
      ebs_size = $evm.root['dialog_ebs_size'].to_i
      ebs_device = $evm.root['dialog_ebs_device'].to_s
      $evm.log("info","User selected Dialogs option = [#{ebs_size}]")

    #dialog_ebs_size_hash = Hash[$evm.root.attributes.sort.collect { |k, v| [k, v] if k.starts_with?('ebs_size') }]
    #ebs = []
    #dialog_ebs_size_hash.each {|k,v| ebs << v.to_i if k.to_s =~ /ebs_size(\d*)/}
  end

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

  instanceid = vm.ems_ref
  log(:info, "Creating and Attaching an EBS volume to instance: #{instanceid}")

  log(:info, "==========================")
  log(:info, "==========================")
  log(:info, "==========================")

  instancezone = ec2.instances[instanceid].availability_zone
  log(:info, "Getting Instance Info #{instancezone}")


  volume = ec2.volumes.create(:size => ebs_size, :availability_zone => instancezone)
  volumeid = volume.id
  log(:info, "#{volumeid}")
  sleep 1 until volume.status == :available
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
