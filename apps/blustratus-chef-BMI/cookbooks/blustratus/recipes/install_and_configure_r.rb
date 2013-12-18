#
# Cookbook Name:: blustratus
# Recipe:: install_and_configure_r
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#


cookbook_file "/tmp/createPackage.R"

bash "Run Rscript" do
  code <<-EOH
	Rscript /tmp/createPackage.R
    EOH
end
