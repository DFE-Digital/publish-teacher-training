name 'psql'
summary 'connect to the psql server for an app'
option :f, 'source_file', 'source sql file to pass to psql to run',
       argument: :optional
option :c, 'sql_command', 'sql string to run',
       argument: :optional

instance_eval(&MCB.remote_connect_options)

run do |opts, _args, _cmd|
  MCB.load_env_azure_settings(opts)
  if MCB.requesting_remote_connection? opts
    MCB::Azure.configure_for_webapp(opts)
  else
    MCB.configure_local_database_env
  end

  ENV['PGPASSWORD'] = ENV['DB_PASSWORD']
  psql_args = ["-h", ENV['DB_HOSTNAME'], "-U", ENV['DB_USERNAME'], "-d", ENV['DB_DATABASE']]

  source_file = opts[:source_file]
  if source_file
    psql_args << "--file"
    psql_args << source_file
  end

  sql_command = opts[:sql_command]
  if sql_command
    psql_args << "--command"
    psql_args << sql_command
  end

  MCB::exec_command("psql", *psql_args)
end
