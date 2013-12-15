#
# Cookbook Name:: imcloud_tools
# Recipe:: clean_yum_repo
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#


bash "Clean yum repositories" do
  code <<-EOH
    yum clean all
  EOH
end