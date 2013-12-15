#
# Cookbook Name:: blustratus
# Recipe:: setup_web_console
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

imcloud_client "BLU Stratus Web Console"

bswc_config = ::File.join(node[:console][:config_prefix], "Config")
install_path_config = ::File.join(node[:console][:install][:path], "Config")

existing_bswc_config = ::File.exists?(bswc_config)

directory "/tmp#{node[:console][:install][:path]}" do
  recursive true
  action :create
end

bash "Unzip Web Console install media to temp directory" do
  code lazy {
    "unzip #{node[:imcloud_client][:return]} \
      -d /tmp#{node[:console][:install][:path]} \
      > /tmp/dsserver.unzip.log" }
  action :run
  not_if { ::File.exists?(install_path_config) }
end

file "Delete Web Console install media" do
  backup false
  path lazy { node[:imcloud_client][:return] }
  action :delete
end

bash "Move existing configuration" do
  code <<-EOH
    rm -f #{bswc_config}/*_overrides.properties
    mv -f #{bswc_config}/* /tmp#{install_path_config}
  EOH
  only_if { existing_bswc_config }
end

bash "Remove existing install directory" do
  code <<-EOH
    rm -rf #{node[:console][:install][:path] }
  EOH
  only_if { existing_bswc_config && bswc_config == install_path_config }
end

directory ::File.dirname( node[:console][:install][:path] ) do
  recursive true
  action :create
end

bash "Move installation from temp directory" do
  code <<-EOH
    mv -f \
      /tmp#{node[:console][:install][:path]} \
      #{node[:console][:install][:path]}
  EOH
end

bash "Create configuration directory" do
  code <<-EOH
    mkdir -p #{bswc_config}
  EOH
  not_if { existing_bswc_config }
end

bash "Create configuration symlink" do
  code <<-EOH
    mv -f #{install_path_config}/* #{bswc_config}
    rm -Rf #{install_path_config}
    ln -s #{bswc_config} #{install_path_config}
  EOH
  only_if { bswc_config != install_path_config }
end

template ::File.join(bswc_config, "dswebserver.properties") do
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
    chmod a+x #{node[:console][:install][:path]}/scripts/setupSSHKeys.sh
  EOH
end
