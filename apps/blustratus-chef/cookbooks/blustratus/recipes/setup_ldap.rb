#
# Cookbook Name:: blustratus
# Recipe:: setup_ldap
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

execute "Encrypting password" do
  command "#{node[:console][:install][:path]}/dsutil/bin/crypt.sh #{node[:ldap][:password]} > /tmp/encrypt_pass"
  action :run
end

directory node[:console][:config_path] do
  action :create
  recursive true
  not_if { ::File.exist?( node[:console][:config_path] ) }
end

directory "#{node[:console][:install][:path]}/ldap" do
  action :create
  recursive true
  not_if { ::File.exist?("#{node[:console][:install][:path]}/ldap") }
end

#execute "ln -s #{node[:console][:config_path]} #{node[:console][:dbDIR]}" do
#  not_if { ::File.exist?("#{node[:console][:install][:path]}/ldap") }
#end
link node[:console][:config_path] do
  to node[:console][:dbDIR]
  not_if { ::File.exist?(node[:console][:dbDIR]) }
end

execute "Taking backup of slapd" do
  command "cp -r /etc/openldap/slapd.d/ /etc/openldap/slapd.d.backup/"
  not_if { ::File.exist?("/etc/openldap/slapd.d.backup/")}
end


%w{olcDatabase={0}config.ldif olcDatabase={-1}frontend.ldif olcDatabase={1}monitor.ldif olcDatabase={2}bdb.ldif}.each do |file_name|
  template "/etc/openldap/slapd.d/cn\=config/#{file_name}" do
    source "#{file_name}.erb"
    owner "root"
    group "root"
    mode 0777
    variables({
       :dir => node[:console][:dbDIR],
       :dc => "blustratus",
       :cn => node[:ldap][:admin]
     })
  end
end


bash "Setup slapd password password" do
  code <<-EOH
	pwd=$(slappasswd -s #{node[:ldap][:password]})
	sed -i 's,olcRootPW.*:,olcRootPW: '${pwd}',' /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif
    EOH
end

#bash "Generating password" do
#  code <<-EOH
#	slappasswd -s #{node[:ldap][:password]} > /tmp/password
#    EOH
#end

#ruby_block "Status" do
#  block do
#    pass = `slappasswd -s #{pwd}`.strip
#    `sed -i 's,olcRootPW.*:,olcRootPW: #{pass},' /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif`
#  end
#end

#file "/tmp/password" do
#	action :delete
#end
################################  Fix config  ################################

template "/etc/openldap/slapd.d/cn\=config.ldif" do
  source "cn\=config.ldif.erb"
  owner "root"
  group "root"
  mode 0777
end


directory node[:ldap][:slapd_location] do
  action :create
  recursive true
  not_if { ::File.exist?( node[:ldap][:slapd_location] ) }
end

cookbook_file ::File.join(node[:ldap][:slapd_location], "slapd-sha2.so")

# TODO: Convert to Chef recipe -- for SHA-256
bash "Setup slapd-sha2" do
  code <<-EOH
    touch /etc/openldap/slapd.d/cn\=config/cn\=module{0}.ldif
    cat << 'EOF' > /etc/openldap/slapd.d/cn\=config/cn\=module{0}.ldif
dn: cn=module{0}
objectClass: olcModuleList
olcModulePath: #{node[:ldap][:slapd_location]}
olcModuleLoad: slapd-sha2.so
EOF
	EOH
	not_if { ::File.exists?("/etc/openldap/slapd.d/cn=config/cn=module{0}.ldif") }
end


execute "creation of DB_CONFIG file" do
  command "cp `rpm -ql openldap-servers | grep DB_CONFIG` #{node[:console][:dbDIR]}/DB_CONFIG"
  only_if { node[:ldap][:first]  == 'YES' }
end

bash "Fix permissions" do
  code <<-EOH
    chown -R ldap:ldap #{node[:console][:config_path]}
    chmod 700 #{node[:console][:config_path]}
    EOH
end

###############################  Start slapd  ################################
service "slapd" do
  action :start
end

##########################  Create initial entries  ##########################
## ONLY DO THIS IF NEW DB ##
template "/tmp/defaultLDIF" do
  source "defaultLDIF.erb"
  owner "root"
  group "root"
  variables({
    :cn => node[:ldap][:admin]
  })
end

bash "Creating default domain" do
  code <<-EOH
    sleep 10
    cat /tmp/defaultLDIF
    ldapadd -x -D "cn=#{node[:ldap][:admin]},dc=blustratus,dc=com" -w #{node[:ldap][:password]} < /tmp/defaultLDIF
    chown -R ldap:ldap #{node[:console][:config_path]}
    sleep 10
  EOH
  only_if { node[:ldap][:first] == 'YES' }
end


bash "ldap commands" do
  code <<-EOH
    ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
      -w #{node[:ldap][:password]} \
      -S "uid=user1,ou=People,dc=blustratus,dc=com" \
      -s #{node[:ldap][:password]}

    ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
      -w #{node[:ldap][:password]} \
      -S "uid=bluadmin,ou=People,dc=blustratus,dc=com" \
      -s #{node[:ldap][:password]}

   ldappasswd -x -D "cn=bluldap,dc=blustratus,dc=com" \
      -w #{node[:ldap][:password]} \
      -S "uid=bluuser,ou=People,dc=blustratus,dc=com" \
      -s #{node[:ldap][:password]}

	ldap_encrypted_password=$(cat /tmp/encrypt_pass)
    #{node[:console][:install][:path]}/scripts/updatedswebserver.sh \
      -ldap.host #{node[:ldap][:ip]} \
      -ldap.port #{node[:ldap][:port]} \
      -ldap.root.passwd $ldap_encrypted_password \
      -ldap.user.home   #{node[:ldap][:home_directory]}
    EOH
end

######################  Change Authconfig to use LDAP  #######################
# Create backup if it doesn't already exist

#if [ ! -d /var/lib/authconfig/backup-ldap/ ]; then
#  authconfig --savebackup=openldap
#fi

execute "backup" do
  command "authconfig --savebackup=openldap"
  not_if { ::File.exists?("/var/lib/authconfig/backup-ldap/") }
end

execute "authconfig" do
  command "authconfig \
            --enableldap \
            --enableldapauth \
            --ldapserver=ldap://#{node[:ldap][:ip]}:#{node[:ldap][:port]} \
            --ldapbasedn=\"dc=blustratus,dc=com\" \
            --enablemkhomedir \
            --enableforcelegacy \
            --update"
end


################### Add pam.d entry for DB2 authentication ###################
cookbook_file "/etc/pam.d/db2" do
  source "db2"
  not_if { ::File.exists?("/etc/pam.d/db2") }
end

bash "Update rsyslog.conf" do
  code <<-EOH
    cat >> /etc/rsyslog.conf << EOF
# Send slapd(8c) logs to /var/log/slapd.log
if \$programname == 'slapd' then /var/log/slapd.log
& ~
EOF
    EOH
end

# Restart the rsyslog service
service "rsyslog" do
  action :restart
end

execute "wait time" do
  command "sleep 10"
end

bash "Update ldap users ssh keys" do
  code <<-EOH
    su bluadmin -c "#{node[:console][:install][:path]}/scripts/setupSSHKeys.sh"
    su bluuser  -c "#{node[:console][:install][:path]}/scripts/setupSSHKeys.sh"
    su user1    -c "#{node[:console][:install][:path]}/scripts/setupSSHKeys.sh"
    EOH
end
