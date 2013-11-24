#
# Cookbook Name:: cognos_bi
# Recipe:: configure_and_start
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

if node[:ipaddress] == node[:db2][:ip]
  bash "Move db2 jar files" do
    code <<-EOH
	  if [ -f "#{node[:db2][:install_path]}/java/db2jcc.jar" ]; then
        mv #{node[:db2][:install_path]}/java/db2jcc*.jar #{node[:cognos][:install_path]}/webapps/p2pd/WEB-INF/lib/
	  fi
      EOH
    action :run
  end
else
  log "Remote DB2 not enabled yet"
  bash "Move db2 jar files" do
    code <<-EOH
      scp root@#{node[:db2][:ip]}:#{node[:db2][:install_path]}/java/db2jcc*.jar #{node[:cognos][:install_path]}/webapps/p2pd/WEB-INF/lib/
      EOH
    action :run
  end
end

template ::File.join(node[:cognos][:install_path], "configuration/cogstartup.xml") do
  variables({
    :total_memory => node[:memory][:total].to_i / 1024 / 1024
      })
end

template ::File.join(node[:cognos][:install_path], "bin64/startup.sh") do
  variables({
    :total_memory => node[:memory][:total].to_i / 1024 / 1024
      })
end


##
## This is a workaround for setting new OS limits.
## TODO: find a better solution
##
#ulimit -n 65535
#ulimit -i 1032252
#ulimit -l unlimited
#ulimit -s unlimited
#ulimit -u unlimited

#remote_file "/opt/ibm/java-x86_64-70/jre/lib/ext/bcprov-jdk14-145.jar" do
#  source "file://#{node[:cognos][:install_path]}/bin64/jre/7.0/lib/ext/bcprov-jdk14-145.jar"
#end

bash "Move bcprov jar" do
  code <<-EOH
    if [ -f "#{node[:cognos][:install_path]}/bin64/jre/7.0/lib/ext/bcprov-jdk14-145.jar" ]; then
      mv #{node[:cognos][:install_path]}/bin64/jre/7.0/lib/ext/bcprov-jdk14-145.jar /opt/ibm/java-x86_64-70/jre/lib/ext/bcprov-jdk14-145.jar
	fi  
    EOH
  action :run
end

#echo "export JAVA_HOME=/opt/ibm/java-x86_64-70/jre" >> ~/.bashrc
#echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${DB2_INSTALL_PATH}/lib64:${DB2_INSTALL_PATH}/lib32:${COGNOS_INSTALL_PATH}/cgi-bin" \
#  >> ~/.bashrc
#
#source ~/.bashrc
#
#echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${DB2_INSTALL_PATH}/lib64:${DB2_INSTALL_PATH}/lib32:${COGNOS_INSTALL_PATH}/cgi-bin" \
#  >> /etc/sysconfig/httpd
bash "Setup Cognos exports" do
  code <<-EOH
    echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:#{node[:db2][:install_path]}/lib64:#{node[:db2][:install_path]}/lib32:#{node[:cognos][:install_path]}/cgi-bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:#{node[:db2][:install_path]}/lib64:#{node[:db2][:install_path]}/lib32:#{node[:cognos][:install_path]}/cgi-bin" >> /etc/sysconfig/httpd
    EOH
  action :run
end


cookbook_file "/etc/httpd/conf.d/cognos.conf" do
end

service "httpd" do
  action :restart
end

bash "Start Cognos BI" do
  code "#{node[:cognos][:install_path]}/bin64/cogconfig.sh -s"
  environment 'JAVA_HOME' => "/opt/ibm/java-x86_64-70/jre"
  action :run
end
