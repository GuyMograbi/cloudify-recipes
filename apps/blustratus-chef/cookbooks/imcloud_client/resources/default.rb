actions :url, :download
default_action :download

attribute :api_key,   :kind_of => String, :regex => /^[a-z0-9]{64}$/
attribute :api_url,   :kind_of => [String, NilClass]
attribute :cloud,     :kind_of => [String, NilClass], :equal_to => ["aws", "ec2", nil]
attribute :geography, :kind_of => [String, NilClass]
attribute :path,      :kind_of => [String, NilClass], :default => "/tmp"
