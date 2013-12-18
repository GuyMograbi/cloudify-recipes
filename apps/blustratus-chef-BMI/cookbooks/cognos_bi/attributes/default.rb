# Inputs:
default[:cognos][:config_path]          = "/"
default[:cognos][:version]              = "10.2.1"
default[:cognos][:fixpack_version]      = "FP1"
default[:cognos][:install_fixpack]      = "NO"
default[:cognos][:install_sdk]          = "YES"
default[:cognos][:cm][:directory]       = "/home/db2inst1"

default[:cognos][:install_path]         = ::File.join(default[:cognos][:config_path], "opt/ibm/cognos")

default[:cognos][:caf][:enabled]        = "false"
default[:cognos][:report_server][:arch] = "64"

# INPUTS FOR IMCLOUD_CLIENT
default[:imcloud][:download_directory]  = "/mnt/blumeta0/downloads"

# INPUTS FOR DB2
default[:cognos][:ip]                   = node['ipaddress']
