log "Restore DB2 Database"

if node[:backup][:download_from_cloud] == "yes"
  raise "Not implemented outside Rightscale"
end


log "Running Database Backup"

execute "restore-database" do
  command "db2 restore DB #{node[:db2][:database][:name]} #{node[:db2][:database][:options]}"
  user node[:db2][:instance][:username]
  only_if { ::File.exists?(local_path) }
end
