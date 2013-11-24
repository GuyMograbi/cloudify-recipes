#
# Cookbook Name:: cognos_bi
# Recipe:: default
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
  %w{httpd libstdc++-devel}.each do |pkg|
    package pkg
  end
  yum_package "libstdc++" do
    version "4.4.7-3.el6"
	arch "i686"
  end
  
  yum_package "libX11" do
    version "1.5.0-4.el6"
	arch "i686"
  end
end


def setup_cognos(name, fullname)
  dir = ::File.join("/mnt", name)

  imcloud_client fullname do
    api_key node[:imcloud][:api][:key]
    action :download
  end
  
  directory dir do
    mode 0755
    action :create
  end

  bash "extract-#{name}" do
    code lazy { "tar --index-file /tmp/#{name}.tar.log -xvvf " + node[:imcloud_client][:return] + " -C #{dir}" }
	action :nothing
  end
  
  bash "install-#{name}" do
    code "#{dir}/linuxi38664h/issetupnx -s /tmp/#{name}.ats"
	action :nothing
  end  

  template "/tmp/#{name}.ats" do
    source "#{name}.ats.erb"
	notifies :run, "bash[extract-#{name}]", :immediately
	notifies :run, "bash[install-#{name}]", :immediately
  end

  file "Delete #{name} media" do
    backup false
    path lazy { node[:imcloud_client][:return] }
    action :delete
  end
end


#unless File.exists?("/opt/ibm/db2.lock")
  setup_cognos("cognos", "Cognos BI #{node[:cognos][:version]}")

  if node[:cognos][:install_fixpack] == "YES"
    setup_cognos("cognosfixpack", "Cognos BI #{node[:cognos][:version]} #{node[:cognos][:fixpack_version]}")
  end

  
  if node[:cognos][:install_sdk] == "YES"
    setup_cognos("cognossdk", "Cognos BI SDK #{node[:cognos][:version]}")
  end
  
#end
