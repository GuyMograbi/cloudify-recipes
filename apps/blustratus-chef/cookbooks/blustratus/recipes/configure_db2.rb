#
# Cookbook Name:: blustratus
# Recipe:: configure_db2
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

###                                               ###
### Workaround for handling new DB2 build levels  ###
###                                               ###

cookbook_file "/var/db2/global.reg" do
  mode 00644
end


# Workaround: DB2 special build expects that '/usr/lib64/libcrypto.so' exist
link "/usr/lib64/libcrypto.so" do
  to "/usr/lib64/libcrypto.so.1.0.0"
  not_if { ::File.exists?("/usr/lib64/libcrypto.so") }
end


execute "Update instance" do
  cwd ::File.join(node[:db2][:install_path], "instance")
  command "./db2iupdt -u #{node[:db2][:fenced][:username]} #{node[:db2][:instance][:username]}"
  only_if { node[:db2][:create_instance] == "NO" }
end

bash "Run db2set" do
  code <<-EOH
	su - #{node[:db2][:instance][:username]} -c "db2stop force"
	su - #{node[:db2][:instance][:username]} -c "db2set DB2_OBJECT_STORAGE_SETTINGS=ON"
	su - #{node[:db2][:instance][:username]} -c "db2set DB2_WORKLOAD=ANALYTICS"
	su - #{node[:db2][:instance][:username]} -c "db2set DB2AUTH=OSAUTHDB"
	su - #{node[:db2][:instance][:username]} -c "db2start"
    EOH
end

bash "Update DB2 config parameters for LDAP authentication" do
  code <<-EOH
    su - #{node[:db2][:instance][:username]} -c "db2 update dbm cfg using AUTHENTICATION SERVER"
    su - #{node[:db2][:instance][:username]} -c "db2 update dbm cfg using SYSADM_GROUP   BLUADMIN"
    su - #{node[:db2][:instance][:username]} -c "db2 update dbm cfg using SYSCTRL_GROUP  BLUDEV"
    su - #{node[:db2][:instance][:username]} -c "db2 update dbm cfg using SYSMAINT_GROUP BLUDEV"
    su - #{node[:db2][:instance][:username]} -c "db2 update dbm cfg using SYSMON_GROUP   BLUDEV"
    EOH
end
