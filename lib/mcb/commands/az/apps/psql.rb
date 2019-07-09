name 'psql'
summary 'connect to the psql server for an app'
# h is used for help so used H instead
option :H, 'host', 'override hostname of database - useful for connecting to restored copies.'\
       ' Just the hostname, not the fully qualified name. E.g. bat-mcapi-restore-psql',
       argument: :optional
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
  user = ENV['DB_USERNAME']
  host = ENV['DB_HOSTNAME']
  if opts[:host]
    host = opts[:host] + ".postgres.database.azure.com"
    # The part of the username after the @ is the actual host you are actually connecting to.
    # The host in hostname is completely irrelevant beyond getting to azure. #HASHTAG_AZURE
    # So we need to replace that in the retrieved settings so we end up on the right postgres server.
    # There was an attempt. https://is.gd/kT9DBe
    user = user.sub(/@.*/, "@#{opts[:host]}")
  end
  psql_args = ["-h", host, "-U", user, "-d", ENV['DB_DATABASE']]

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
