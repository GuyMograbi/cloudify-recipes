#
# Cookbook Name:: blustratus
# Recipe:: setup_web_console
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

imcloud_client "BLU Stratus Web Console" do
  api_key node[:imcloud][:api][:key]
  action :download
end

directory node[:console][:install][:path] do
  recursive true
  action :create
end


config_prefix_config = ::File.join(node[:console][:config_prefix], "Config")
install_path_config = ::File.join(node[:console][:install][:path], "Config")


bash "unzip console media" do
  code lazy { "unzip #{node[:imcloud_client][:return]} -d #{node[:console][:install][:path]} \
                     > /tmp/dsserver.unzip.log" }
  action :run
  not_if { ::File.exists?(install_path_config) } 
end

file "Delete console media" do
  backup false
  path lazy { node[:imcloud_client][:return] }
  action :delete
end

bash "Move config directory" do
  code <<-EOH
    mv #{install_path_config} #{config_prefix_config}
    EOH
  not_if { ::File.exists?(config_prefix_config) }
end

link config_prefix_config do
  to install_path_config
  only_if { node[:console][:install][:path] != node[:console][:config_prefix] }
end


template ::File.join(config_prefix_config, "dswebserver.properties") do
end

#chown -R ${DB2_INST_USERNAME}.${DB2_INST_GROUP} ${BSWC_INSTALL_PATH}
#chown -R ${DB2_INST_USERNAME}.${DB2_INST_GROUP} ${BSWC_CONFIG_PREFIX}
#directory node[:console][:install][:path] do
#  owner node[:db2][:instance][:username]
#  group node[:db2][:instance][:group]
#  recursive true
#end
#
#directory node[:console][:config_prefix] do
#  owner node[:db2][:instance][:username]
#  group node[:db2][:instance][:group]
#  recursive true
#end

bash "fix permissions of console binaries" do
  code <<-EOH
    chown -R #{node[:db2][:instance][:username]}.#{node[:db2][:instance][:group]} #{node[:console][:install][:path]}
    chown -R #{node[:db2][:instance][:username]}.#{node[:db2][:instance][:group]} #{node[:console][:config_prefix]}
    chmod u+x #{node[:console][:install][:path]}/bin/*.sh
    chmod u+x #{node[:console][:install][:path]}/scripts/*.sh
    chmod u+x #{node[:console][:install][:path]}/dsutil/bin/*.sh
    EOH
end