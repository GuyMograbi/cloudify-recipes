#
# Cookbook Name:: db2
# Recipe:: default
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "debian", "ubuntu"
  execute "install-required-packages" do
    command "apt-get install -y libgd2-xpm:i386 libgphoto2-2:i386 ia32-libs-multiarch ia32-libs"
  end
  %w{libstdc++6 lib32stdc++6 libaio1 libpam0g:i386}.each do |pkg|
    package pkg
  end
  
  link "/lib/i386-linux-gnu/libpam.so.0" do
    to "/lib/libpam.so.0"
  end
else
  %w{compat-libstdc++-33 libstdc++-devel dapl dapl-devel libibverbs-devel}.each do |pkg|
    package pkg
  end
  gem_package "ruby-shadow" do
    action :install
  end
  yum_package "pam.i686" do
    version "1.1.1-13.el6"
	action :install
  end
end


if ::File.directory?(node[:db2][:install_path])
  log "DB2 ALREADY INSTALLED"

  file ::File.join(node[:db2][:instance][:home_dir], "sqllib/db2nodes.cfg") do 
    content "0 #{node[:hostname]} 0\n"
    action :create
  end

  
else
	
  [node[:db2][:data_path], node[:db2][:backup_path], node[:db2][:log_path]].each do |dir|
    directory dir do
      mode 00777
      action :create
	  recursive true
    end
  end
  
  if node[:db2][:create_os_users] == "YES"
  
    [:instance, :fenced, :das].each do |user_type|
      u = node[:db2][user_type]
  
  	group u[:group] do
        #gid u[:gid].to_i if u.available? :gid
        action :create
      end
  
      user u[:username] do
        supports :manage_home => true
        uid u[:uid].to_i if u.available? :uid
        gid u[:gid].to_i if u.available? :gid
        home u[:home_dir] if u.available? :home_dir
        shell "/bin/bash"
        password u[:password].crypt('$1$anibmsalt')
      end
    end
  
  end
  
  
  log "Installing #{node[:db2][:download_name]}"

  imcloud_client node[:db2][:download_name] do
    api_key node[:imcloud][:api][:key]
    action :download
  end
  
  bash "extract-db2" do
    code lazy { "tar --index-file /tmp/db2.tar.log -xvvf " + node[:imcloud_client][:return] + " -C /mnt" }
    action :nothing
  end
  
  bash "install-db2" do
    code "/mnt/server/db2setup -r /tmp/db2.rsp"
    action :nothing
  end  
  
  template "/tmp/db2.rsp" do
    source node[:db2][:response_file]
    action :create
    notifies :run, "bash[extract-db2]", :immediately
    notifies :run, "bash[install-db2]", :immediately
  end

  file "Delete db2 media" do
    backup false
    path lazy { node[:imcloud_client][:return] }
    action :delete
  end
  
  
  [node[:db2][:data_path], node[:db2][:backup_path], node[:db2][:log_path]].each do |dir|
    directory dir do
      mode 00755
      owner node[:db2][:instance][:username]
      group node[:db2][:instance][:group]
      recursive true
    end
  end


  template File.join(node[:db2][:instance][:home_dir], ".bashrc") do
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
  end
  
   
  licence_file = "/tmp/db2#{node[:db2][:license]}.lic"
  unless node[:db2][:license].nil?
    cookbook_file licence_file
  
    bash "Update DB2 License" do
      command "db2licm -a #{licence_file}"
      user node[:db2][:instance][:username]
    end
  end
   
  # Update db2nodes.cfg
  file ::File.join(node[:db2][:instance][:home_dir], "sqllib/db2nodes.cfg") do 
    content "0 #{node[:hostname]} 0\n"
    action :create
    only_if { node[:db2][:update_nodes_config] == "YES" }
  end
 
  bash "Create DB2 Services" do
    code <<-EOH
echo "DB2_db2inst1      60000/tcp
DB2_db2inst1_1    60001/tcp
DB2_db2inst1_2    60002/tcp
DB2_db2inst1_END  60003/tcp
db2c_db2inst1     #{node[:db2][:port]}/tcp" >> /etc/services
    EOH
    only_if { node[:db2][:create_services] == "YES" }
  end
 
 
  # Create DAS
  bash "Create DAS" do
    code <<-EOH
      if [ -e #{node[:db2][:das][:home_dir]}/das ]; then
        rm -rf #{node[:db2][:das][:home_dir]}/das.old
        mv -f #{node[:db2][:das][:home_dir]}/das #{node[:db2][:das][:home_dir]}/das.old
      fi
      #{node[:db2][:install_path]}/instance/dascrt #{node[:db2][:das][:username]}
      EOH
    only_if { node[:db2][:create_das] == "YES" }
  end
 
end
