#
# Cookbook Name:: dc_logger
# Recipe:: install_client
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

DC_LOGGER_GEM = "/tmp/dc_logger_client-0.1.2.gem"

include_recipe "build-essential"

# Install for Chef
gem_package "dc_logger_client" do
  source DC_LOGGER_GEM
  action :nothing
end

chef_gem "dc_logger_client" do
  source DC_LOGGER_GEM
  action :nothing
end

cookbook_file DC_LOGGER_GEM do
  mode 00644
  notifies :install, "gem_package[dc_logger_client]", :immediately
  notifies :install, "chef_gem[dc_logger_client]", :immediately
end

file DC_LOGGER_GEM do
  action :delete
end
