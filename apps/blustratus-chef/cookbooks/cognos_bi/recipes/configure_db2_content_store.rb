#
# Cookbook Name:: cognos_bi
# Recipe:: configure_db2_content_store
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

# begin
  #TODO: FIX THIS
  #test_connection "CM"

  directory node[:cognos][:cm][:directory] do
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
    recursive true
    action :create
  end

  template "/tmp/cognos_cm.ddl" do
    variables({
      :cognos_cm_directory => node[:cognos][:cm][:directory]
  	})
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
  end

  bash "Create CM database" do
    code <<-EOH
  	  su - #{node[:db2][:instance][:username]} -c "db2 -t -f /tmp/cognos_cm.ddl"
  	EOH
  end

  bash "Update CM dft_table_org" do
    code <<-EOH
  	  su - #{node[:db2][:instance][:username]} -c "db2 update db cfg for CM using DFT_TABLE_ORG ROW"
    EOH
  end

# rescue
#   log "Using current CM database"
# end
