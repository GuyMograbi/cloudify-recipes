define :test_connection, :user => "db2inst1" do
  log params.inspect
  execute "Test connection to #{params[:name]}" do
    code <<-EOH
	  su - #{params[:user]} -c "db2 connect to #{params[:name]}"
	EOH
	returns [4]
	action :nothing
  end.run_action(:run)
end