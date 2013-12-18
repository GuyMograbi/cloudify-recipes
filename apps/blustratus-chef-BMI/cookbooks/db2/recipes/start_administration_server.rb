log "Starting DB2 Administration Server"

bash "db2admin start" do
  user node[:db2][:das][:username]
  action :run
end
