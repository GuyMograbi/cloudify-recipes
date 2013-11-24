#
# Cookbook Name:: blustratus
# Recipe:: configure_and_start_web_console
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#


begin
  test_connection "METADB"
  
  directory node[:console][:metadb][:directory] do
    recursive true
    action :create
  end

  directory node[:console][:metadb][:directory] do
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
    recursive true
  end
  
  bash "create_meta_db" do
    code <<-EOH
      su - #{node[:db2][:instance][:username]} -c "db2 CREATE DB METADB ON #{node[:console][:metadb][:directory]}"
    EOH
  end

  # Set DFT_TABLE_ORG to ROW, as DB2_WORKLOAD=ANAlYTICS sets it to COLUMN by default
  bash "Set DB2_WORKLOAD=ANAlYTICS" do
    code <<-EOH
      su - #{node[:db2][:instance][:username]} -c "db2 update db cfg for METADB using DFT_TABLE_ORG ROW"
    EOH
  end
  
rescue
  log "Using existing METADB database"
end

file ::File.join(config_prefix_config, "metadb.properties") do
  owner node[:db2][:instance][:username]
  group node[:db2][:instance][:group]
  mode "0755"
  action :create
end

execute "Set DB2_WORKLOAD=ANAlYTICS" do
  command "cd #{node[:console][:install][:path]} && bin/updatemetadb.sh \
  -dataServerType DB2LUW -databaseName metadb \
  -host #{node[:db2][:ip]} -port #{node[:db2][:port]} \
  -user #{node[:db2][:instance][:username]} -password #{node[:db2][:instance][:password]}"
  user node[:db2][:instance][:username]
end

execute "Start Web Console" do
  cwd node[:console][:install][:path]
  command "bin/start.sh"
  user node[:db2][:instance][:username]
end

execute "Init Web Console" do
  cwd node[:console][:install][:path]
  command "bin/init.sh"
  user node[:db2][:instance][:username]
  returns [0,4]
end
