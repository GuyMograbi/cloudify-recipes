log "Stopping DB2 Administration Server"

bash "db2admin stop" do
  user node[:db2][:das][:username]
  action :run
end
