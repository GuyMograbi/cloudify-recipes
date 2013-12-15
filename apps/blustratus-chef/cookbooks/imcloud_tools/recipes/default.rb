#
# Cookbook Name:: imcloud_tools
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

#package     "ruby"
#package     "rubygems"
#package     "ruby-devel"
#gem_package "json"
#chef_gem    "json"
#
#bash "Mount Softlayer metadata" do
#  code <<-EOH
#    if [ ! -d "/softlayer" ]; then
#      df -h | grep "/dev/xvdh1"
#	  if [ $? <> 0 ]; then
#	    mkdir /softlayer && mount /dev/xvdh1 /softlayer
#		if [ ! -f "/softlayer/meta.js" ]; then
#		  umount /softlayer
#		  rmdir /softlayer
#		fi
#	  fi
#	fi
#    EOH
#end

