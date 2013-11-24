name             'db2'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures db2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'imcloud_client'
depends 'imcloud_tools'
depends 'dc_logger'

recipe "db2::default",                     "Installs the DB2."

recipe "db2::start",                       "Start DB2"
recipe "db2::stop",                        "Stop DB2"
recipe "db2::start_administration_server", "Start DB2 Administration Server"
recipe "db2::stop_administration_server",  "Stop DB2 Administration Server"
recipe "db2::create_database",             "Create DB2 Database"
recipe "db2::backup_database",             "Backup DB2 Database"
recipe "db2::restore_database",            "Restore DB2 Database"


### INPUTS FOR INSTANCE OWNER

attribute "db2/instance/username",
   :display_name => "DB2 Instance owner username",
   :description => "Username for the DB2 instance owner.",
   :required => "recommended",
   :default => "db2inst1",
   :recipes => ["db2::default", "db2::start_db2", "db2::stop_db2", "db2::start_db2_administration_server", "db2::stop_db2_administration_server", "db2::create_database", "db2::backup_database", "db2::restore_database"]

attribute "db2/instance/password",
   :display_name => "DB2 Instance owner password",
   :description => "Password for the DB2 instance owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["db2::default"]
   
attribute "db2/instance/group",
   :display_name => "DB2 Instance owner group",
   :description => "Primary Group for the DB2 instance owner.",
   :required => "recommended",
   :default => "db2iadm1",
   :recipes => ["db2::default"]

attribute "db2/instance/home_dir",
   :display_name => "DB2 Instance owner home directory",
   :description => "Home directory for the DB2 Instance owner.",
   :required => "optional",
   :recipes => ["db2::default"]
   
attribute "db2/instance/uid",
   :display_name => "DB2 Instance owner uid",
   :description => "User ID for the DB2 instance owner.",
   :required => "optional",
   :recipes => ["db2::default"]

attribute "db2/instance/gid",
   :display_name => "DB2 Instance owner gid",
   :description => "Group ID for the DB2 instance owner.",
   :required => "optional",
   :recipes => ["db2::default"]

### INPUTS FOR DAS USER
   
attribute "db2/das/username",
   :display_name => "DB2 das owner username",
   :description => "Username for the DB2 das owner.",
   :required => "recommended",
   :default => "dasusr1",
   :recipes => ["db2::default"]

attribute "db2/das/password",
   :display_name => "DB2 das owner password",
   :description => "Password for the DB2 das owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["db2::default"]
   
attribute "db2/das/group",
   :display_name => "DB2 das owner group",
   :description => "Primary Group for the DB2 das owner.",
   :required => "recommended",
   :default => "dasadm1",
   :recipes => ["db2::default"]
   
attribute "db2/das/home_dir",
   :display_name => "DB2 das home directory",
   :description => "Home directory for the DB2 das owner.",
   :required => "optional",
   :recipes => ["db2::default"]

attribute "db2/das/uid",
   :display_name => "DB2 das owner uid",
   :description => "User ID for the DB2 das owner.",
   :required => "optional",
   :recipes => ["db2::default"]

attribute "db2/das/gid",
   :display_name => "DB2 das owner gid",
   :description => "Group ID for the DB2 das owner.",
   :required => "optional",
   :recipes => ["db2::default"]
   
### INPUTS FOR FENCED USER
   
attribute "db2/fenced/username",
   :display_name => "DB2 Fenced owner username",
   :description => "Username for the DB2 fenced owner.",
   :required => "recommended",
   :default => "db2fenc1",
   :recipes => ["db2::default"]

attribute "db2/fenced/password",
   :display_name => "DB2 Fenced owner password",
   :description => "Password for the DB2 fenced owner.",
   :required => "recommended",
   :default => "passw0rd",
   :recipes => ["db2::default"]
   
attribute "db2/fenced/group",
   :display_name => "DB2 Fenced owner group",
   :description => "Primary Group for the DB2 fenced owner.",
   :required => "recommended",
   :default => "db2fadm1",
   :recipes => ["db2::default"]

attribute "db2/fenced/home_dir",
   :display_name => "DB2 Fenced owner home directory",
   :description => "Home directory for the DB2 Fenced owner.",
   :required => "optional",
   :recipes => ["db2::default"]
   
attribute "db2/fenced/uid",
   :display_name => "DB2 Fenced owner uid",
   :description => "User ID for the DB2 fenced owner.",
   :required => "optional",
   :recipes => ["db2::default"]

attribute "db2/fenced/gid",
   :display_name => "DB2 Fenced owner gid",
   :description => "Group ID for the DB2 fenced owner.",
   :required => "optional",
   :recipes => ["db2::default"]
   
### INPUTS FOR DB2

attribute "db2/install_prefix",
  :display_name => "DB2 Install prefix",
  :description => "The location on disk where DB2 will be installed.",
  :required => "recommended",
  :choice => ["/", "/mnt/ephemeral/"],
  :default => "/",
  :recipes => ["db2::default"]
 
attribute "db2/data_path",
  :display_name => "DB2 Data Directory",
  :description => "The location on disk where the DB2 Data Directory will be installed.",
  :required => "recommended",
  :default => "/mnt/database",
  :recipes => ["db2::default"]

attribute "db2/backup_path",
  :display_name => "DB2 Backup Directory",
  :description => "The location on disk where the DB2 Backups reside.",
  :required => "recommended",
  :recipes => ["db2::default"]

attribute "db2/log_path",
  :display_name => "DB2 Log Directory",
  :description => "The location on disk where the DB2 Logs reside.",
  :required => "recommended",
  :recipes => ["db2::default"]  

attribute "db2/download_name",
  :display_name => "Download name for imcloud_client",
  :description => "The Download name for imcloud_client",
  :required => "optional",
  :recipes => ["db2::default"]  
  
attribute "db2/license",
   :display_name => "DB2 License",
   :description => "Which DB2 license would you like to use?",
   :required => "recommended",
   :choice => ["aese_c", "awse_c"],
   :default => "awse_c",
   :recipes => ["db2::default"]

attribute "db2/update_nodes_config",
   :display_name => "DB2 update DB2 nodes config",
   :description => "Would you like to update the db2nodes.cfg?",
   :required => "recommended",
   :choice => ["YES", "NO"],
   :default => "YES",
   :recipes => ["db2::default"]

attribute "db2/create_services",
   :display_name => "DB2 create DB2 services",
   :description => "Would you like to create /etc/services?",
   :required => "recommended",
   :choice => ["YES", "NO"],
   :default => "YES",
   :recipes => ["db2::default"]

attribute "db2/create_das",
   :display_name => "DB2 create DB2 DAS",
   :description => "Would you like to create DB2 DAS?",
   :required => "recommended",
   :choice => ["YES", "NO"],
   :default => "YES",
   :recipes => ["db2::default"]
   
attribute "db2/system",
   :display_name => "DB2 System name",
   :description => "The name of the DB2 system.",
   :required => "recommended",
   :default => "DB2onRS",
   :recipes => ["db2::default"]

attribute "db2/force",
   :display_name => "Force",
   :description => "Would you like to force the DB2 Command?",
   :required => "recommended",
   :choice => ["yes", "no"],
   :default => "no",
   :recipes => ["db2::stop_db2"]

attribute "db2/database/name",
   :display_name => "Database name",
   :description => "The name of the DB2 Database.",
   :required => "required",
   :type => "string",
   :recipes => ["db2::create_database"]

attribute "db2/database/options",
   :display_name => "DB2 Database Options",
   :description => "Any extra options to pass to the DB2 command.",
   :required => "optional",
   :recipes => ["db2::create_database"]

   
## INPUTS FOR INSTALL

attribute "db2/edition",
   :display_name => "DB2 Edition",
   :description => "The edition of DB2 to install.",
   :required => "required",
   :type => "string",
   :choice => ["Enterprise", "Express", "Express-C"],
   :recipes => ["db2::default"]

attribute "db2/version",
   :display_name => "Database name",
   :description => "The version of DB2 to install.",
   :required => "required",
   :type => "string",
   :choice => ["9.7", "9.7.5", "10.0", "10.1", "10.5", "10.5.1"],
   :recipes => ["db2::default"]
   
attribute "db2/port",
   :display_name => "Database port",
   :description => "The port of DB2.",
   :required => "recommended",
   :type => "string",
   :default => "50001",
   :recipes => ["db2::default"]
   
attribute "db2/text_search",
   :display_name => "Text Search",
   :description => "Install Text Search.",
   :required => "recommended",
   :type => "string",
   :default => "YES",
   :choice => ["YES", "NO"],
   :recipes => ["db2::default"]
   
attribute "db2/create_instance",
   :display_name => "Create Instance",
   :description => "Do you want to create the DAS instance?",
   :required => "recommended",
   :type => "string",
   :default => "YES",
   :choice => ["YES", "NO"],
   :recipes => ["db2::default"]
   
attribute "db2/create_os_users",
   :display_name => "Create OS Users",
   :description => "Do you want to create the OS users?",
   :required => "recommended",
   :type => "string",
   :default => "YES",
   :choice => ["YES", "NO"],
   :recipes => ["db2::default"]