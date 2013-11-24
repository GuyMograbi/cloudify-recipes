name             'dc_logger'
maintainer       'IBM'
maintainer_email 'imcloud@ca.ibm.com'
license          'All rights reserved'
description      'Installs/Configures dc_logger'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'build-essential'

#recipe "dc_logger::default", "Installs the dc_logger."
recipe "dc_logger::install_client", "Installs the dc_logger client."
#recipe "dc_logger::install_server", "Installs the dc_logger server."
