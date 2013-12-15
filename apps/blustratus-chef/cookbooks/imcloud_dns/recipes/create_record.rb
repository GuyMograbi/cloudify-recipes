#
# Cookbook Name:: imcloud_dns
# Recipe:: create_record
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
  ttl node[:dns][:ttl].to_i
  ip_address node[:dns][:ip_address]
  
  action :create
end
