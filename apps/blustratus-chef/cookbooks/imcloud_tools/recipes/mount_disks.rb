#
# Cookbook Name:: imcloud_tools
# Recipe:: mount_disks
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

mount_points = node[:disk][:mount_points].split(",")
disk_devices = node[:disk][:devices].split(",")
filesystems = node[:disk][:filesystems].split(",")
disk_options = node[:disk][:options].split(";")



mount_points.each_with_index do |mount_point, index|
  directory mount_point do
    recursive true
    action :create
  end

  mount mount_point do
    device disk_devices[index]
    fstype filesystems[index]
    options disk_options[index]
    action [:mount, :enable]
  end
end
