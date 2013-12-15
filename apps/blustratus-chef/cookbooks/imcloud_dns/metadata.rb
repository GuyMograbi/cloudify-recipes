name             'imcloud_dns'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures imcloud_dns'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "imcloud_dns::default", "Installs the imcloud_dns gem."
recipe "imcloud_dns::create_record", "Create a DNS record."
recipe "imcloud_dns::delete_record", "Delete a DNS record."
recipe "imcloud_dns::update_record", "Update a DNS record."

attribute "cloud/access_key_id",
   :display_name => "AWS Access Key ID",
   :description => "",
   :required => "required",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::delete_record", "imcloud_dns::update_record"]

attribute "cloud/secret_access_key",
   :display_name => "AWS SECRET Access Key",
   :description => "",
   :required => "required",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::delete_record", "imcloud_dns::update_record"]
   
attribute "dns/hosted_zone_id",
   :display_name => "Route53 Hosted Zone ID",
   :description => "The Hosted Zone of your domain.",
   :required => "recommended",
   :default => "Z32XGGBXLCBYKV",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::delete_record", "imcloud_dns::update_record"]


attribute "dns/hostname",
   :display_name => "FQDN Hostname",
   :description => "The fully qualified hostname you want to work with ending in a DOT (e.g. test.imdemocloud.com.).",
   :required => "required",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::delete_record", "imcloud_dns::update_record"]

attribute "dns/type",
   :display_name => "DNS Record Type",
   :description => "The DNS Record TYPE you want to create.",
   :required => "recommended",
   :choice => ["A", "CNAME", "MX", "AAAA", "TXT", "PTR", "SRV", "SPF", "NS", "SOA"],
   :default => "A",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::delete_record", "imcloud_dns::update_record"]

attribute "dns/ttl",
   :display_name => "DNS Record TTL",
   :description => "The DNS Record TTL you want to create.",
   :required => "recommended",
   :default => "60",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::update_record"]
   
attribute "dns/ip_address",
   :display_name => "DNS Record IP",
   :description => "The DNS Record IP Address you want to create.",
   :required => "required",
   :recipes => ["imcloud_dns::create_record", "imcloud_dns::update_record"]
