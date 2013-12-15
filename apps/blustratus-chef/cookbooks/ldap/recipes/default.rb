#
# Cookbook Name:: ldap
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

%w{ openldap openldap-clients openldap-servers }.each do |pkg|
  yum_package pkg
end

bash "Install nss-pam-ldapd" do
  code <<-EOH
    yum clean all
	yum -y install nss-pam-ldapd
    EOH
end

