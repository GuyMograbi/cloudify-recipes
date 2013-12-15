#
# Cookbook Name:: blustratus
# Recipe:: setup_bootstrap_site
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'ruby_build'

cookbook_file "rails_bootstrap.tar.gz" do
  path "/tmp/rails_bootstrap.tar.gz"
end

bash "extract blu bootstrap website" do
  code <<-EOH
    mkdir -p /var/www/blu-bootstrap
    tar --index-file /tmp/bootstrap.tar.log -xvvf /tmp/rails_bootstrap.tar.gz -C /var/www/blu-bootstrap
  EOH
  action :run
end

template "/var/www/blu-bootstrap/config/bswc.yml"

bash "set config/database.yml" do
  code <<-EOH
    cd /var/www/blu-bootstrap/config
    cp database.yml.example database.yml
  EOH
end

file "Delete Rails bootstrap media" do
  backup false
  path "/tmp/rails_bootstrap.tar.gz"
  action :delete
end

ruby_build_ruby '1.9.3-p484' do
  prefix_path '/usr/local'
  action :install
end

bash "Install Redis" do
  code <<-EOH
    cd /opt

    wget http://download.redis.io/releases/redis-2.8.2.tar.gz
    tar xzf redis-2.8.2.tar.gz
    rm -f redis-2.8.2.tar.gz

    mv redis-2.8.2 redis
    cd redis
    make

    ln -fs /opt/redis/src/redis-server /usr/local/bin
    ln -fs /opt/redis/src/redis-cli /usr/local/bin
  EOH
end

gem_package "bundler"
yum_package "sqlite-devel"

bash "Install Bootstrap gems" do
  cwd "/var/www/blu-bootstrap"
  code 'bundle install'
end

template "/etc/init.d/rails" do
  owner "root"
  group "root"
  mode 0755
  variables({
     :cloud => node[:cloud][:provider]
   })
end

bash "add rails to startup" do
  code <<-EOH
    chkconfig --add rails
    chkconfig rails on
  EOH
end

cookbook_file "rc.local.append" do
  path "/tmp/rc.local.append"
end

bash "Update rc.local" do
  code <<-EOH
    cat /tmp/rc.local.append >> /etc/rc.local
  EOH
end

service "rails" do
  action :start
end
