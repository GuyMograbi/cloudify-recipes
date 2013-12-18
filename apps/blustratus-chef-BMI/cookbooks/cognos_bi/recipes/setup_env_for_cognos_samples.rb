#
# Cookbook Name:: cognos_bi
# Recipe:: setup_env_for_cognos_samples
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

# Task 35767: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35767
imcloud_client "BLU Accelerator Cognos Samples" do
  path ::File.join(node[:cognos][:install_path], 'deployment')
end

imcloud_client "BLU Accelerator Cognos Warehouse Packs" do
  path ::File.join(node[:cognos][:install_path], 'deployment')
end

# Task 35768: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35768
directory ::File.join(node[:imcloud][:download_directory], 'cognos') do
  recursive true
  action :create
end

imcloud_client "BLU Initial Sample Model" do
  path ::File.join(node[:imcloud][:download_directory], 'cognos')
end


# Task 35769: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35769
imcloud_client "BLU Cognos Sample Images"

bash 'extract_module' do
  code <<-EOH
    unzip -u /tmp/cognos_sample_images.zip -d #{node[:cognos][:install_path]}/webcontent/
  EOH
end


# Task 35831: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35831
directory File.join(node[:imcloud][:download_directory], 'samples') do
  recursive true
  action :create
end

imcloud_client "BLU Sample DB" do
  path ::File.join(node[:imcloud][:download_directory], 'samples')
end
