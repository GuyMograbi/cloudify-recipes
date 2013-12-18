#
# Cookbook Name:: imcloud_dns
# Recipe:: delete_record
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

imcloud_dns node[:dns][:hostname] do
  access_key_id node[:cloud][:access_key_id]
  secret_access_key node[:cloud][:secret_access_key]
  hosted_zone_id node[:dns][:hosted_zone_id]
  
  type node[:dns][:type]
  
  action :delete
end
