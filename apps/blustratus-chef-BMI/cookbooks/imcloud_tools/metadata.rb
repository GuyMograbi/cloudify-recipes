name             'imcloud_tools'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures imcloud_tools'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'


recipe "imcloud_tools::default", "Imcloud_tools."
recipe "imcloud_tools::mount_disks", "Mounts disks."

attribute "disk/mount_points",
   :display_name => "Mount Points",
   :description => "Comma-separated list of mounts points (e.g. /mnt/disk1,/mnt/disk2).",
   :required => "required",
   :type => "string",
   :recipes => ["imcloud_tools::mount_disks"]

attribute "disk/devices",
   :display_name => "Devices",
   :description => "Comma-separated list of devices (e.g. /dev/xvdf,/dev/xvdg).",
   :required => "required",
   :type => "string",
   :recipes => ["imcloud_tools::mount_disks"]

attribute "disk/filesystems",
   :display_name => "File Systems",
   :description => "Comma-separated list of filesystems (e.g. xfs,ext3).",
   :required => "required",
   :type => "string",
   :recipes => ["imcloud_tools::mount_disks"]
   
attribute "disk/options",
   :display_name => "Disk options",
   :description => "Comma-separated list of disk options (e.g. defaults.noatime.nodiratime,defaults.noatime.nodiratime).",
   :required => "required",
   :type => "string",
   :recipes => ["imcloud_tools::mount_disks"]