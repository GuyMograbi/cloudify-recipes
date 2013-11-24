default[:console][:install][:path]     = "/opt/ibm/dsserver"
default[:console][:config_prefix]      = "/opt/ibm/dsserver"
default[:console][:metadb][:directory] = "/home/db2inst1"


default[:ldap][:ip]                    = node[:fqdn]
default[:ldap][:port]                  = "389"
default[:ldap][:password]              = "passw0rd"