require 'logger'

module IMCloud
  class DNS
    def initialize(access_key_id, secret_access_key, hosted_zone_id, logger = nil)
      require 'rubygems'
      require 'aws-sdk'
	
	  @access_key_id = access_key_id
	  @secret_access_key = secret_access_key
	  @hosted_zone_id = hosted_zone_id
      @logger = logger || Logger.new(STDOUT)
    end

    def rrsets
      route53 = AWS::Route53.new(:access_key_id => @access_key_id, :secret_access_key => @secret_access_key)
     
      hosted_zone = route53.hosted_zones[@hosted_zone_id]
      hosted_zone.rrsets
    end

    def create(hostname, type, ttl, ip_address)
	  rrsets.create(hostname, type, :ttl => ttl, :resource_records => [{:value => ip_address}])
    end

    def delete(hostname, type)
	  rrsets[hostname, type].delete
    end
	
    def update(hostname, type, ttl, ip_address)
	  begin
	    delete(hostname, type)
	  rescue => e
        puts "Error deleting '#{hostname}': #{e}"
	  ensure
	    create(hostname, type, ttl, ip_address)
      end
    end

  end
end