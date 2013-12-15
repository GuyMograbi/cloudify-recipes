#
# Cookbook Name:: blustratus
# Recipe:: create_and_activate_swap
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

###                                               ###
### Workaround for handling new DB2 build levels  ###
###                                               ###


bash "Create SWAP" do
  code <<-EOH
    mkdir -p #{File.dirname(node[:swap][:file])}
    dd if=/dev/zero of=#{node[:swap][:file]} bs=1#{node[:swap][:type]} count=#{node[:swap][:memory]}
  
    mkswap #{node[:swap][:file]}
    chmod 600 #{node[:swap][:file]}

    swapon #{node[:swap][:file]}
  
    echo "#{node[:swap][:file]} swap swap defaults 0 0" >> /etc/fstab
  EOH
  not_if { ::File.exists?( node[:swap][:file] ) }
end