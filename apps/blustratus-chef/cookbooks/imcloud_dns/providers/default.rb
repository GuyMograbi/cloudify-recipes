action :create do
  ruby_block "IMCloud DNS CREATE" do
    block do
	  dns = IMCloud::DNS.new(new_resource.access_key_id, new_resource.secret_access_key, new_resource.hosted_zone_id, Chef::Log)
	  dns.create(new_resource.name, new_resource.type, new_resource.ttl, new_resource.ip_address)
	end
  end
end


action :update do
  ruby_block "IMCloud DNS UPDATE" do
    block do
	  dns = IMCloud::DNS.new(new_resource.access_key_id, new_resource.secret_access_key, new_resource.hosted_zone_id, Chef::Log)
	  dns.update(new_resource.name, new_resource.type, new_resource.ttl, new_resource.ip_address)
	end
  end
end

action :delete do
  ruby_block "IMCloud DNS DELETE" do
    block do
	  dns = IMCloud::DNS.new(new_resource.access_key_id, new_resource.secret_access_key, new_resource.hosted_zone_id, Chef::Log)
	  dns.delete(new_resource.name, new_resource.type)
	end
  end
end