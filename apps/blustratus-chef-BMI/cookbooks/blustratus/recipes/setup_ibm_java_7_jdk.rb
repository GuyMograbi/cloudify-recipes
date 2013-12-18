#
# Cookbook Name:: blustratus
# Recipe:: setup_ibm_java_7_jdk
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
  arch "i686"
  action :install
  end
end


imcloud_client "IBM Java JDK 7" do
  api_key node[:imcloud][:api][:key]
  action :download
end

rpm_package "ibm-java-x86_64-sdk.x86_64" do
  source "/tmp/ibm-java-x86_64-sdk-7.0-6.0.x86_64.rpm"
  action :install
end

file "Delete IBM JAVA media" do
  backup false
  path lazy { node[:imcloud_client][:return] }
  action :delete
end

bash "Update java alternatives" do
  code <<-EOH
    update-alternatives --install /usr/bin/java java /opt/ibm/java-x86_64-70/jre/bin/java 1
  EOH
end
