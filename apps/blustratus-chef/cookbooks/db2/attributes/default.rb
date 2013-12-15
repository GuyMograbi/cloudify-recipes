default[:db2][:version]             = "10.5.1"
default[:db2][:edition]             = "Enterprise"
default[:db2][:license]             = "awse_c"

default[:db2][:download_name]       = "DB2 #{default[:db2][:edition]} #{default[:db2][:version]}"

default[:db2][:install_prefix]      = "/"

default[:db2][:ip]                  = node['ipaddress']
default[:db2][:port]                = "50000"

default[:db2][:text_search]         = "NO"
default[:db2][:system]              = "DB2onChef"

default[:db2][:data_path]           = "/mnt/bludata0/db2/databases"
default[:db2][:backup_path]         = "/mnt/bludata0/db2/backup"
default[:db2][:log_path]            = "/mnt/bludata0/db2/log"

default[:db2][:create_os_users]     = "YES"
default[:db2][:create_instance]     = "YES"

### INPUTS FOR INSTANCE USER

default[:db2][:instance][:username] = "db2inst1"
default[:db2][:instance][:password] = "passw0rd"
default[:db2][:instance][:group]    = "db2iadm1"
default[:db2][:instance][:home_dir] = ::File.join('/home', default[:db2][:instance][:username])
default[:db2][:instance][:uid]      = ""
default[:db2][:instance][:gid]      = "102"

### INPUTS FOR DAS USER

default[:db2][:das][:username]      = "dasusr1"
default[:db2][:das][:password]      = "passw0rd"
default[:db2][:das][:group]         = "dasadm1"
default[:db2][:das][:home_dir]      = ::File.join('/home', default[:db2][:das][:username])
default[:db2][:das][:uid]           = ""
default[:db2][:das][:gid]           = "101"
 
### INPUTS FOR FENCED USER
   
default[:db2][:fenced][:username]   = "db2fenc1"
default[:db2][:fenced][:password]   = "passw0rd"
default[:db2][:fenced][:group]      = "db2fadm1"
default[:db2][:fenced][:home_dir]   = ::File.join('/home', default[:db2][:fenced][:username])
default[:db2][:fenced][:uid]        = ""
default[:db2][:fenced][:gid]        = "103"

if default[:db2][:create_os_users] == "YES"
  default[:db2][:instance][:uid] ||= '502'
  default[:db2][:fenced][:uid]   ||= '503'
  default[:db2][:das][:uid]      ||= '501'
end


default[:db2][:major_version] = default[:db2][:version][/^\d+\.\d+/] if default[:db2][:version]

case default[:db2][:edition]
when "Enterprise"
  default[:db2][:media_location] = "/tmp/v10.5fp1_linuxx64_server.tar.gz"
  default[:db2][:response_file]  = "enterprise_#{default[:db2][:version]}.rsp.erb"
  default[:db2][:install_path]   = "#{default[:db2][:install_prefix]}opt/ibm/db2/V#{default[:db2][:major_version]}"
when "Express"
  default[:db2][:media_location] = "/tmp/v#{default[:db2][:version]}_linuxx64_exp.tar.gz"
  default[:db2][:response_file] = "express_#{default[:db2][:version]}.rsp.erb"
  default[:db2][:install_path]   = "#{default[:db2][:install_prefix]}opt/ibm/db2/V#{default[:db2][:major_version]}"
when "Express_C"
  default[:db2][:media_location] = "/tmp/v#{default[:db2][:version]}_linuxx64_expc.tar.gz"
  default[:db2][:response_file] = "expressc_#{default[:db2][:version]}.rsp.erb"
  default[:db2][:install_path]   = "#{default[:db2][:install_prefix]}opt/ibm/db2/V#{default[:db2][:major_version]}"      
end
