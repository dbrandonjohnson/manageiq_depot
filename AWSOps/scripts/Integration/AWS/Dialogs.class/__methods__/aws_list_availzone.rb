#
# CFME Automate Method: AWS_List_AvailZone
#
# Notes: This is a template for creating new methods
#
# Inputs:
#
begin
  # Method for logging
  def log(level, message)
    @method = 'AWS_List_AvailZone'
    $evm.log(level, "#{@method} - #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}") }
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root

  require 'rubygems'


  aws = $evm.vmdb(:ems_amazon).first

  #aws = $evm.root['ext_management_system']
  log(:info, "AWS: #{aws.inspect}")
  #log(:info, "AWS Virtual Columns: #{aws.virtual_columns_inspect}")
  aws.methods.sort.each {|method| log(:info, "METHOD: AWS.#{method}")}
  #log(:info, "AWS: #{aws.authentication_userid}")
  #log(:info, "AWS: #{aws.authentication_password}")
  log(:info, "AWS: Region: #{aws.hostname}")



  az_hash = {}
  az_hash[nil] = nil


  log(:info, "Information from CloudForms ----> #{aws.availability_zones}")

  for az in aws.availability_zones
    log(:info, "trying to get the AZ Name ---> #{az.name}")
    az_hash[az.name] = "#{az.name}"
  end
  log(:info, "here is the list of availability zones ---> #{az_hash}")


  $evm.object["sort_by"] = "description"
  $evm.object["sort_order"] = "ascending"
  $evm.object["data_type"] = "string"
  $evm.object["required"] = "true"
  $evm.object['values'] = az_hash
  log(:info, "Dynamic drop down values: #{$evm.object['values']}")



  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue 
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
