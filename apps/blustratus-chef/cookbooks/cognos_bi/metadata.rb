name             'cognos_bi'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures Cognos BI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'imcloud_client'
depends 'imcloud_tools'
depends 'dc_logger'
depends 'db2'

supports "redhat"

recipe "cognos_bi::default",                      "Installs Cognos BI."
recipe "cognos_bi::configure_db2_content_store",  "Configure DB2 Content Store."
recipe "cognos_bi::setup_env_for_cognos_samples", "Setup the environment for the Cognos Samples."
recipe "cognos_bi::configure_and_start",          "Configure and start Cognos BI."


# Inputs:

attribute "cognos/config_path",
   :display_name => "Cognos Config Path",
   :description => "Where would you like to install Cognos?",
   :required => "recommended",
   :default => "/",
   :recipes => ["cognos_bi::default", "cognos_bi::setup_env_for_cognos_samples"]

attribute "cognos/version",
   :display_name => "Cognos Version",
   :description => "What version of Cognos would you like to install?",
   :required => "recommended",
   :default => "10.2.1",
   :recipes => ["cognos_bi::default"]
   
attribute "cognos/fixpack_version",
   :display_name => "Cognos Fixpack Version",
   :description => "What Fixpack version would you like to install?",
   :required => "recommended",
   :default => "FP1",
   :recipes => ["cognos_bi::default"]

attribute "cognos/install_fixpack",
   :display_name => "Install Fixpack?",
   :description => "Would you like to install the Cognos BI Fixpack?",
   :required => "recommended",
   :choice => ["YES", "NO"],
   :default => "NO",
   :recipes => ["cognos_bi::default"]

attribute "cognos/install_sdk",
   :display_name => "Install SDK?",
   :description => "Would you like to install the Cognos BI SDK?",
   :required => "recommended",
   :choice => ["YES", "NO"],
   :default => "YES",
   :recipes => ["cognos_bi::default"]
   
attribute "cognos/cm/directory",
   :display_name => "Cognos CM Directory",
   :description => " Directory to be used for CM database.",
   :required => "recommended",
   :default => "/home/db2inst1",
   :recipes => ["cognos_bi::configure_db2_content_store"]
   
   

# INPUTS FOR IMCLOUD_CLIENT

attribute "imcloud/download_directory",
   :display_name => "IMCloud Downloads directory",
   :description => "IMCloud Downloads directory",
   :required => "recommended",
   :default => "/mnt/blumeta0/downloads",
   :recipes => ["cognos_bi::setup_env_for_cognos_samples"]


# INPUTS FOR DB2

attribute "db2/ip",
   :display_name => "DB2 IP",
   :description => "The IP of DB2. (Set to ENV:PUBLIC_IP).",
   :required => "required",
   :type => "string",
   :recipes => ["cognos_bi::configure_and_start"]
   
   
   
   
attribute "cognos/caf/enabled",
   :display_name => "Cognos CAF Enabled?",
   :description => "Would you like to enable Cognos Application Firewall ?",
   :required => "recommended",
   :choice => ["true", "false"],
   :default => "true",
   :recipes => ["cognos_bi::configure_and_start"]

attribute "cognos/report_server/arch",
   :display_name => "Cognos BI report server architecture",
   :description => "Cognos BI report server architecture",
   :required => "recommended",
   :choice => ["32", "64"],
   :default => "32",
   :recipes => ["cognos_bi::configure_and_start"]
