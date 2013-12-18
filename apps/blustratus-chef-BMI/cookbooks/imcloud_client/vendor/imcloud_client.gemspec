Gem::Specification.new do |s|
  s.name        = 'imcloud_client'
  s.version     = '0.1.8'
  s.add_runtime_dependency 'thor', '~> 0.18.1'
  s.add_runtime_dependency 'mime-types', '1.25'
  s.add_runtime_dependency 'rest-client', '1.6.7'
  s.add_runtime_dependency 'json', '>= 1.6.1'
  s.executables << 'imcloud_client'
  s.date        = '2013-09-30'
  s.summary     = "IMCloud Client"
  s.description = "This is the client to access the IMCloud API"
  s.authors     = ["Bradley Steinfeld", "Antonio Cangiano"]
  s.email       = 'bsteinfe@ca.ibm.com'
  s.files       = ["lib/imcloud_client.rb"]
  s.homepage    = 'http://rubygems.org/gems/imcloud_client'
  s.license     = 'MIT'
end