#
# Cookbook Name:: blustratus
# Recipe:: setup_firstboot_for_db2_php_site
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

log "Provider: #{node[:cloud][:provider]}"


%w{httpd httpd-devel php php-pear php-devel expect mod_ssl}.each do |pkg|
  package pkg
end


imcloud_client "BLU Stratus PHP Site" do
  api_key node[:imcloud][:api][:key]
  action :download
end

bash "Extract PHP Site Media" do
  code lazy { "tar --index-file /tmp/blu_stratus_php_site.tar.log -xvvf " + node[:imcloud_client][:return] + " -C /tmp" }
  action :run
end

file "Delete PHP Site Media" do
  backup false
  path lazy { node[:imcloud_client][:return] }
  action :delete
end

bash "Setup PHP Site Media" do
  code <<-EOH
    tar -xvvf /tmp/phpsite/rheldb2.tar -C /tmp/phpsite
    tar -xvvf /tmp/phpsite/blushift_bootstrap_site.tar.gz -C /var/www/html/
    tar -xvvf /tmp/phpsite/httpd-2.2.25.tar.gz -C /tmp
    EOH
  action :run
end


## Update sudoers
bash "Update sudoers" do
  code <<-EOH
    echo "apache  ALL=NOPASSWD:   ALL" >> /etc/sudoers
    sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
    EOH
  action :run
end

## Setup PEAR/PECL
#pear channel-update pear.php.net
php_pear_channel 'pear.php.net' do
  action :update
end

bash "Install ibm_db2 pear/pecl module" do
  code <<-EOH
    pear install Console_Getopt HTML_Common HTML_Menu HTML_Template_Sigma HTML_TreeMenu PEAR XML_RPC
    EOH
  action :run
end
#%w{Console_Getopt HTML_Common HTML_Menu HTML_Template_Sigma HTML_TreeMenu PEAR XML_RPC json}.each do |pear_pkg|
#  php_pear pear_pkg do
#    action :install
#  end
#end


#pecl channel-update pecl.php.net
php_pear_channel 'pecl.php.net' do
  action :update
end
bash "Install ibm_db2 pear/pecl module" do
  code <<-EOH
    pecl install ibm_db2 <<-EOF
    #{node[:db2][:install_path]}
    EOF
    EOH
  environment 'IBM_DB_HOME' => node[:db2][:instance][:home_dir]
  action :run
end


#### Update http.conf
###mv -f /tmp/rheldb2/httpd.conf /etc/httpd/conf/httpd.conf
##remote_file "/etc/httpd/conf/httpd.conf" do
##  source "file:///tmp/phpsite/httpd.conf"
##end
##
#### Update php.ini
###mv -f /tmp/rheldb2/php.ini /etc/php.ini
##remote_file "/etc/php.ini" do
##  source "file:///tmp/phpsite/php.ini"
##end

bash "Update http.conf and php.ini" do
  code <<-EOH
    mv -f /tmp/phpsite/httpd.conf /etc/httpd/conf/httpd.conf
    mv -f /tmp/phpsite/php.ini /etc/php.ini
    EOH
  action :run
end

## Fix mod_file_cache
bash "Fix mod_file_cache" do
  code <<-EOH
    cd /tmp/httpd-2.2.25/modules/cache
    apxs -i -a -c mod_file_cache.c
    apxs -i -a -c mod_mem_cache.c
    sed -i 's/LoadModule mem_cache_module/#LoadModule mem_cache_module/g' /etc/httpd/conf/httpd.conf
    EOH
  action :run
end

## Install aws-sdk gem
#gem install aws-sdk
#

#service httpd restart
#service sshd restart
service "httpd" do
  action :restart
end

service "sshd" do
  action :restart
end
