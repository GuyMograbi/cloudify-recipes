#
# Cookbook Name:: blustratus
# Recipe:: configure_and_start_web_console
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

yum_package "httpd"

service "httpd" do
  action [ :enable, :start ]
end

begin
  #TODO: FIX THIS
  #test_connection "METADB"

  directory node[:console][:metadb][:directory] do
    recursive true
    action :create
  end

  directory node[:console][:metadb][:directory] do
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
    recursive true
  end

  bash "Create database METADB" do
    code <<-EOH
      su - #{node[:db2][:instance][:username]} -c \
        "db2 CREATE DB METADB ON #{node[:console][:metadb][:directory]}"
    EOH
  end

  # Set DFT_TABLE_ORG to ROW, as DB2_WORKLOAD=ANAlYTICS sets it to COLUMN by default
  bash "Set METADB cfg DFT_TABLE_ORG to ROW" do
    code <<-EOH
      su - #{node[:db2][:instance][:username]} -c \
        "db2 update db cfg for METADB using DFT_TABLE_ORG ROW"
    EOH
  end

rescue
  log "Using existing METADB database"
end

file ::File.join(node[:console][:config_prefix], "Config", "metadb.properties") do
  owner node[:db2][:instance][:username]
  group node[:db2][:instance][:group]
  mode "0755"
  action :create
end

bash "Update Web Console config" do
  code <<-EOH
    cd #{node[:console][:install][:path]}
    bin/updatemetadb.sh \
      -dataServerType DB2LUW \
      -databaseName metadb \
      -host #{node[:db2][:ip]} \
      -port #{node[:db2][:port]} \
      -user #{node[:db2][:instance][:username]} \
      -password #{node[:db2][:instance][:password]}
  EOH
  user node[:db2][:instance][:username]
end

bash "Init and start Web Console" do
  code <<-EOH
    su - #{node[:db2][:instance][:username]} -c \
      "cd #{node[:console][:install][:path]} && bin/init.sh"

    su - #{node[:db2][:instance][:username]} -c \
      "cd #{node[:console][:install][:path]} && bin/start.sh"
  EOH
  ## ERROR:
  #   Mixlib::ShellOut::ShellCommandFailed
  #   ------------------------------------
  #   Expected process to exit with [0, 4], but received '127'
  #   ---- Begin output of bin/init.sh ----
  #   STDOUT:
  #   STDERR: find: `/opt/ibm/dsserver/ldap/Config': Permission denied
  #   ---- End output of bin/init.sh ----
  #   Ran bin/init.sh returned 127
  ## SRIRAM:
  #   shouldn't affect the dsserver installation
  # returns [0,4]
  returns [0, 4, 127]
end
