name             'blustratus'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures blustratus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'php'

depends 'imcloud_client'
depends 'imcloud_tools'
depends 'dc_logger'
depends 'db2'
depends 'cognos_bi'
#depends 'openldap'

depends 'ruby_build'

recipe "blustratus::default", "Installs blustratus."
recipe "blustratus::configure_os", "Configure OS for Blu Stratus."
recipe "blustratus::configure_db2", "Configure DB2 for Blu Stratus."
recipe "blustratus::setup_ibm_java_7_jre", "Install IBM Java 7 JRE."
recipe "blustratus::install_ibm_data_architect", "Install IBM Data Architect."
recipe "blustratus::setup_web_console", "Setup Blu Stratus Web Console."
recipe "blustratus::setup_firstboot_for_db2_php_site", "Setup firstboot for DB2 PHP Site."
recipe "blustratus::configure_and_start_web_console", "Configure and start Blu Stratus Web Console."
recipe "blustratus::callback", "Callback to server."
recipe "blustratus::create_storage", "Sets up the iSCSI storage (expand to EBS)."
recipe "blustratus::create_and_activate_swap", "Create and activate swap"
recipe "blustratus::setup_bootstrap_site", "Setup Rails bootstrap site"
recipe "blustratus::install_and_configure_r", "Install and configure R"


attribute "db2/ip",
   :display_name => "DB2 IP",
   :description => "The IP of DB2. (Set to ENV:PUBLIC_IP).",
   :required => "required",
   :type => "string",
   :recipes => ["blustratus::setup_web_console", "blustratus::setup_firstboot_for_db2_php_site"]

attribute "cognos/ip",
   :display_name => "Cognos IP",
   :description => "The IP of Cognos. Set to (ENV:PUBLIC_IP).",
   :required => "required",
   :type => "string",
   :recipes => ["blustratus::setup_web_console"]

attribute "console/install/path",
   :display_name => "Web Console Install Path",
   :description => "Web Console Install Path.",
   :required => "recommended",
   :default => "/opt/ibm/dsserver",
   :recipes => ["blustratus::setup_web_console"]

attribute "console/config_prefix",
   :display_name => "Web Console Config Prefix",
   :description => "Web Console Config Prefix.",
   :required => "recommended",
   :default => "/opt/ibm/dsserver",
   :recipes => ["blustratus::setup_web_console"]

   
attribute "console/metadb/directory",
   :display_name => "Web Console METADB Directory",
   :description => "Web Console METADB Direcory.",
   :required => "recommended",
   :default => "/home/db2inst1",
   :recipes => ["blustratus::setup_web_console"]
