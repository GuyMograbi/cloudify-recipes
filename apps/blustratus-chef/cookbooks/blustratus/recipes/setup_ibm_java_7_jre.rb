#
# Cookbook Name:: blustratus
# Recipe:: setup_ibm_java_7_jre
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#


case node[:platform]
when "debian", "ubuntu"
  log "Debian/Ubuntu not supported"
  exit 1
else
  yum_package "libstdc++" do
    version "4.4.7-3.el6"
	arch "i686"
	action :install
  end
end


imcloud_client "IBM Java JRE 7" do
  api_key node[:imcloud][:api][:key]
  action :download
end

rpm_package "ibm-java-x86_64-jre.x86_64" do
  source "/tmp/ibm-java-x86_64-jre-7.0-5.0.x86_64.rpm"
  action :install
end

file "Delete IBM JAVA media" do
  backup false
  path lazy { node[:imcloud_client][:return] }
  action :delete
end
