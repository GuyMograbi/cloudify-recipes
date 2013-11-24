log "Stopping DB2"

bash "db2stop" do
  code <<-EOH
	su - #{node[:db2][:instance][:username]} -c "db2stop #{node[:db2][:force] == 'YES' ? 'force' : ''}"
  EOH
end
