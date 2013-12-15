ruby_block "Callback to" do
  block do
    require 'uri'
	require 'net/https'
#    url = "#{node[:callback][:protocol]}://#{node[:callback][:hostname]}:#{node[:callback][:port]}" +
#	      "/blu_stratus/server_bootstrap_complete/#{node[:callback][:params][:id]}"

    #host = "https://184.173.182.94:3002"
    #path = "/blu_stratus/server_bootstrap_complete/1"
	host = "#{node[:callback][:protocol]}://#{node[:callback][:hostname]}:#{node[:callback][:port]}"
    path = "/blu_stratus/server_bootstrap_complete/#{node[:callback][:params][:id]}"

	uri = URI.parse("#{host}#{path}")
	
	http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	
	http.start do
      response = http.get("#{host}#{path}")
      #@test_response = JSON(response.body)["profile"]
	  puts response.body.inspect
    end
  end
  action :run
end



#knife bootstrap  <IP>  --ssh-user root --ssh-password xxx -r "role[db2],recipe[blustratus::callback]" --json-attributes "{\"callback\": {\"hostname\": \"blu-for-cloud-test.imdemocloud.com\", \"params\": {\"id\": \"<SERVER_ID>\"} }}"


#knife bootstrap  108.168.168.45  --ssh-user root --ssh-password Xn7dsaV5 -r "recipe[blustratus::callback]" --json-attributes "{\"callback\": {\"hostname\": \"184.173.182.94\", \"port\": \"3002\", \"params\": {\"id\": \"1\"} }}"