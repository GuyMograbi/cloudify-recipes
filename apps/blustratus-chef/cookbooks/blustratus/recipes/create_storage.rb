#
# Cookbook Name:: blustratus
# Recipe:: create_storage
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

yum_package "iscsi-initiator-utils"


node[:iscsi].each do |iscsi|

  file "/etc/iscsi/iscsid.conf" do
    action :delete
    only_if { ::File.exists?("/etc/iscsi/iscsid.conf") }
  end

  template "/etc/iscsi/iscsid.conf" do
    variables({
      username: isci[:username],
      password: isci[:password],
    })
  end

  service "iscsi" do
    action :restart
  end

  bash "Run iscsiadm" do
    code <<-EOH
      target=$(iscsiadm -m discovery -t sendtargets -p #{iscsi[:ip_address]} | cut -f2 -d" ")

      iscsiadm -m node --logoutall all
      iscsiadm -m node --targetname $target -p #{iscsi[:ip_address]} -o update -n node.session.auth.username -v #{iscsi[:username]}
      iscsiadm -m node --targetname $target -p #{iscsi[:ip_address]} -o update -n node.session.auth.password -v #{iscsi[:password]}
      iscsiadm -m node --targetname $target -p #{iscsi[:ip_address]} -l
      iscsiadm -m node --logoutall all
      iscsiadm -m node --loginall all
    EOH
  end

end

service "iscsi" do
  action :restart
end

node[:iscsi].each_with_index do |iscsi, index|
  bash "Format and mount" do
    code <<-EOH
      ## Get usernames and devices from iscsid catalog
      usernames=$( find /sys/devices/platform/host* -name username -exec cat '{}' \; )
      devices=$( find /sys/devices/platform/host* -name block\* -exec ls '{}' \; )

      ## Transform them into arrays for convenience
      usernames=(${usernames//,/ })
      devices=(${devices//,/ })

      ## Find corresponding device
      # Split by current username
      device=${usernames%#{iscsi[:username]}*}
      # Convert result into array
      device=(${device//,/ })
      # The length is equivalent to the position of the current username
      idx=${#device[@]}
      # Get corresponding device
      device=${devices[$idx]}

      #{ "mkfs.ext4 -F /dev/$device" if iscsi[:format] == "YES" }

      mkdir #{iscsi[:mount_dir]}
      mount /dev/$device #{iscsi[:mount_dir]}

      echo "/dev/$device #{iscsi[:mount_dir]} ext4 _netdev 0 0" > /etc/fstab
    EOH
  end
end

template "/etc/iscsi/iscsid.conf" do
  variables({
    username: '',
    password: '',
  })
end

service "iscsi" do
  action :restart
end

service "iscsi" do
  action :enable
end
