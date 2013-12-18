log "Backup DB2 Database"

log "Running Database Backup"

cd = execute "create-database" do
  command "db2 backup DB #{node[:db2][:database][:name]} #{node[:db2][:database][:options]}"
  user node[:db2][:instance][:username]
  action :nothing
end
cd.run_action(:run)

if node[:backup][:save_to_cloud] == "yes"
  log "Saving Backup to cloud"

  raise "Not implemented outside Rightscale"
end
