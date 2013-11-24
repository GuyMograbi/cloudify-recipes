log "Starting DB2"

bash "db2start" do
  code <<-EOH
    su - #{node[:db2][:instance][:username]} -c "db2start"
  EOH
  returns [0, 1]
end
