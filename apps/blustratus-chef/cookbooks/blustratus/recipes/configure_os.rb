#
# Cookbook Name:: blustratus
# Recipe:: configure_os
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

#
# Configure OS for BLU Stratus
#

# Increase system limits
#echo "
#* soft nofile 65535
#* hard nofile 65535
#
#* soft sigpending 1032252
#* hard sigpending 1032252
#
#* soft memlock unlimited
#* hard memlock unlimited
#
#* soft stack unlimited
#* hard stack unlimited
#
#* soft nproc unlimited
#* hard nproc unlimited" >> /etc/security/limits.conf

#directory "/mnt/ephemeral/opt/ibm" do
#  recursive true
#  mode 0755
#  action :create
#end

#link "/opt/ibm" do
#  to "/mnt/ephemeral/opt/ibm"
#end
