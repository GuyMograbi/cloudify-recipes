default[:cloud][:access_key_id]      = "1SWVDDY8DR5ZEHBJNG82"
default[:cloud][:secret_access_key]  = "PJpYKjBDiwDM2gc0PXKckYmfP0d4cLNJqk/OKWiy"
default[:dns][:hosted_zone_id]       = "Z32XGGBXLCBYKV"

default[:dns][:hostname]             = node["fqdn"]
default[:dns][:ip_address]           = node["ipaddress"]
default[:dns][:type]                 = "A"
default[:dns][:ttl]                  = "60"
