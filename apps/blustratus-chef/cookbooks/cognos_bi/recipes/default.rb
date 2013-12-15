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
  %w{httpd libstdc++-devel mod_ssl}.each do |pkg|
    package pkg
  end

  %w{libstdc++ libX11}.each do |pkg|
    yum_package pkg do
	  arch "i686"
	  action :install
    end
  end
end


def setup_cognos(name, fullname)
  dir = ::File.join("/mnt", name)

  directory dir do
    mode 0755
    action :create
  end

  imcloud_client fullname do
    api_key node[:imcloud][:api][:key]
    action :download
  end

  bash "extract #{name}" do
    code lazy { "sleep 30 && tar --index-file /tmp/#{name}.tar.log -xvvf " + node[:imcloud_client][:return] + " -C #{dir}" }
	action :nothing
  end

  bash "install #{name}" do
    code <<-EOH
	  #{dir}/linuxi38664h/issetupnx -s /tmp/#{name}.ats
      EOH
	action :nothing
  end

  template "/tmp/#{name}.ats" do
    source "#{name}.ats.erb"
	notifies :run, "bash[extract #{name}]", :immediately
	notifies :run, "bash[install #{name}]", :immediately
  end

  file "Delete #{name} media" do
    backup false
    path lazy { node[:imcloud_client][:return] }
    action :delete
  end
end


setup_cognos("cognos", "Cognos BI #{node[:cognos][:version]}")

if node[:cognos][:install_fixpack] == "YES"
  setup_cognos("cognosfixpack", "Cognos BI #{node[:cognos][:version]} #{node[:cognos][:fixpack_version]}")
end

if node[:cognos][:install_sdk] == "YES"
  setup_cognos("cognossdk", "Cognos BI SDK #{node[:cognos][:version]}")
end
