name "blustratus_singlenode_prep"
description "BluStratus single-node to build on SoftLayer role"
run_list  "role[base]",
          "recipe[blustratus::configure_os]"
# Attributes applied if the node doesn't have it set already.
default_attributes()
# Attributes applied no matter what the node has set already.
override_attributes "db2" => { "download_name" => "DB2 for BLU Stratus" },
                    "cloud" => { "provider" => "SOFTLAYER" },
                    "ldap" => { "first" => "YES" },
                    "imcloud" => {
                      "api" => {
                        "key" => "2f085845cae03d084f1f522ce1a0c9c49f4374f15da192783872bc23cff17ee4",
                        "url" => "https://staging.imdemocloud.com/api"
                      }
                    }
