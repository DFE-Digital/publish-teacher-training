name 'psql'
summary 'connect to the psql server for an app'
option :f, 'source_file', 'source sql file to pass to psql to run',
       argument: :optional

instance_eval(&MCB.remote_connect_options)

run do |opts, _args, _cmd|
  MCB.load_env_azure_settings(opts)
  if MCB.requesting_remote_connection? opts
    MCB::Azure.configure_for_webapp(opts)
  end

  ENV['PGPASSWORD'] = ENV['DB_PASSWORD']
  psql = "psql -h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']}"
  source_file = opts[:source_file]
  psql = "#{psql} --file '#{source_file}'" if source_file

  # could have used verbose() here, but it's worth being certain which psql server you are connected to
  puts psql

  exec(psql)
end
