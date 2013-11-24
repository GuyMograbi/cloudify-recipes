action :url do
  ruby_block "IMCloud Client URL" do
    block do
	
	  require 'rubygems'
	  require 'imcloud_client'
      
      IMCloudClient.configure do |config|
        config.api_key = new_resource.api_key if new_resource.api_key
        config.api_url = new_resource.api_url if new_resource.api_url
      end
      
      params = {}
      
	  url = IMCloudClient.url(new_resource.name, params)
	  
	  node.normal[:imcloud_client][:return] = url
	  
      puts url
	end
  end
end


action :download do
  ruby_block "IMCloud Client DOWNLOAD" do
    block do
	
	  require 'rubygems'
      require 'imcloud_client'
	  
      IMCloudClient.configure do |config|
        config.api_key = new_resource.api_key if new_resource.api_key
        config.api_url = new_resource.api_url if new_resource.api_url
      end
          
      params = {}
      
      filename = IMCloudClient.download(new_resource.path, new_resource.name, params)
	  
	  node.normal[:imcloud_client][:return] = filename
	  
	  new_resource.updated_by_last_action(true)
	  
	  Chef::Log.info "[imcloud_client]: create file #{filename}"
	end
  end
end
