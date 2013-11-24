name             'imcloud_client'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures imcloud_client'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'build-essential'

recipe "imcloud_client::default", "Installs the imcloud_client gem."

attribute "imcloud/api/create_yaml",
   :display_name => "Create imcloud_client YAML?",
   :description => "Should we create the imcloud_client.yml?",
   :default => "NO",
   :required => "recommended",
   :choice => ["NO", "YES"],
   :recipes => ["imcloud_client::default"]

attribute "imcloud/api/key",
   :display_name => "IMCloud API Key",
   :description => "The API Key to use for imcloud_client API calls.",
   :required => "optional",
   :recipes => ["imcloud_client::default"]   

attribute "imcloud/api/url",
   :display_name => "IMCloud API URL",
   :description => "The API URL to use for imcloud_client API calls.",
   :required => "optional",
   :default => "https://my.imdemocloud.com:443/api",
   :recipes => ["imcloud_client::default"]   
