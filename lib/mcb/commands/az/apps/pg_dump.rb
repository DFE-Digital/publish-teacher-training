name 'pg_dump'
summary 'backup the psql server for an app'
option :f, 'target_file', 'target file',
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
  target_file = opts[:target_file]
  target_file ||= "#{opts[:env] || ENV['DB_HOSTNAME']}_" \
    "#{ENV['DB_DATABASE']}_#{Time.now.utc.strftime('%Y%m%d_%H%M%S')}.sql"
  cmd = "pg_dump --encoding utf8 --clean --if-exists " \
      "-h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']} " \
      "--file '#{target_file}'"

  MCB::exec_command(cmd)
end
