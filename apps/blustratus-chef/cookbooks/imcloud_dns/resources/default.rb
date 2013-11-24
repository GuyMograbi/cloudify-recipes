actions :create, :update, :delete
default_action :update

attribute :access_key_id,     :kind_of => String
attribute :secret_access_key, :kind_of => String
attribute :hosted_zone_id,    :kind_of => String, :default => "Z32XGGBXLCBYKV", :regex => /^[A-Z0-9]{14}$/
attribute :type,              :kind_of => String, :default => "A", :equal_to => ["A", "CNAME", "MX", "AAAA", "TXT", "PTR", "SRV", "SPF", "NS", "SOA"]
attribute :ip_address,        :kind_of => [String, NilClass], :regex => /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/
#attribute :name,              :kind_of => String
attribute :ttl,               :kind_of => [Integer, NilClass], :default => 60

