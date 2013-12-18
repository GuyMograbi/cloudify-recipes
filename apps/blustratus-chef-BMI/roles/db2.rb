name "db2"
description "Base DB2 role"
run_list  "role[base]",
          "recipe[db2]",
		  "recipe[db2::start]"
# Attributes applied if the node doesn't have it set already.
default_attributes()
# Attributes applied no matter what the node has set already.
override_attributes()
