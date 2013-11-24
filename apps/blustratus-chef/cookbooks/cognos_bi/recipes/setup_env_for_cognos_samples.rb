#
# Cookbook Name:: db2
# Recipe:: setup_env_for_cognos_samples
#
# Copyright 2013, IBM
#
# All rights reserved - Do Not Redistribute
#

# Task 35767: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35767
#remote_file File.join(node[:cognos][:config_path], 'deployment') do
#  source "/tmp/cognos_samples/IBM_BLU_Acc_Cognos_Samples.zip"
#end

imcloud_client "BLU Accelerator Cognos Samples" do
  api_key node[:imcloud][:api][:key]
  path File.join(node[:cognos][:install_path], 'deployment')
  action :download
end


# Task 35768: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35768
directory File.join(node[:imcloud][:download_directory], 'cognos') do
  recursive true
  action :create
end

#remote_file File.join(node[:imcloud][:download_directory], 'cognos') do
#  source "/tmp/cognos_samples/initialSampleModel.fmd"
#end
imcloud_client "BLU Initial Sample Model" do
  api_key node[:imcloud][:api][:key]
  path File.join(node[:imcloud][:download_directory], 'cognos')
  action :download
end



# Task 35769: https://sdijazzccm05.svl.ibm.com:9452/jazz/web/projects/DataStudio_WEB#action=com.ibm.team.workitem.viewWorkItem&id=35769
imcloud_client "BLU Cognos Sample Images" do
  api_key node[:imcloud][:api][:key]
  action :download
end

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

#remote_file File.join(node[:imcloud][:download_directory], 'samples') do
#  source "/tmp/cognos_samples/sampledb.tar.gz"
#end
imcloud_client "BLU Sample DB" do
  api_key node[:imcloud][:api][:key]
  path File.join(node[:imcloud][:download_directory], 'samples')
  action :download
end
