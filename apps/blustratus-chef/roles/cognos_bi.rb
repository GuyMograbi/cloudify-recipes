name "cognos_bi"
description "Base cognos_bi role"
run_list  "role[base]",
          "recipe[cognos_bi]"
# Attributes applied if the node doesn't have it set already.
default_attributes()
# Attributes applied no matter what the node has set already.
override_attributes()
