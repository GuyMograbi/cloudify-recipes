#
# Cookbook Name:: blustratus
# Recipe:: setup_ldap
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

%w{ openldap openldap-clients openldap-servers }.each do |pkg|
  yum_package pkg
end


bash "Install nss-pam-ldapd" do
  command "yum -y install nss-pam-ldapd"
end

cookbook_file "/tmp/setup_ldap.sh" do
  mode 00755
end

#TODO: Convert to Chef
bash "Setup LDAP" do
  command "/tmp/setup_ldap.sh"
  environment 'BSWC_INSTALL_PATH'  => node[:console][:install][:path],
              'BSWC_CONFIG_PREFIX' => node[:console][:config_prefix],
              'LDAP_IP'            => node[:ldap][:ip],
              'LDAP_PORT'          => node[:ldap][:port],
              'LDAP_PASSWORD'      => node[:ldap][:password]
end
