#
# Cookbook Name:: imcloud_client
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

IMCLOUD_GEM = "/tmp/imcloud_client-0.1.8.gem"

include_recipe "build-essential"

# Install for Chef
gem_package "imcloud_client" do
  source IMCLOUD_GEM
  action :nothing
end

chef_gem "imcloud_client" do
  source IMCLOUD_GEM
  action :nothing
end

cookbook_file IMCLOUD_GEM do
  mode 00644
  notifies :install, "gem_package[imcloud_client]", :immediately
  notifies :install, "chef_gem[imcloud_client]", :immediately
end

file IMCLOUD_GEM do
  action :delete
end

directory '/etc/imcloud' do
  mode 00755
  action :create
end

if node[:imcloud][:api][:create_yaml] == "YES"
  template "/etc/imcloud/imcloud_client.yml" do
    source "imcloud_client.yml.erb"
    mode 00644
  end
end
