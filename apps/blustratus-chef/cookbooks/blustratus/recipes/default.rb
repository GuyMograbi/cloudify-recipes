#
# Cookbook Name:: imcloud_client
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

chef_gem "aws-sdk" do
  action :install
end

# Install for Chef
gem_package "aws-sdk" do
  action :install
end

# Install on OS
gem_package "aws-sdk" do
  gem_binary node['languages']['ruby']['gem_bin']
  action :install
end
