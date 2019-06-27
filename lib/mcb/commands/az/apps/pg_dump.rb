name 'pg_dump'
summary 'backup the psql server for an app'
option :f, 'target_file', 'target file',
  argument: :optional

instance_eval(&MCB.remote_connect_options)

run do |opts, args, _cmd|
  MCB.load_env_azure_settings(opts)
  if MCB.requesting_remote_connection? opts
    MCB::Azure.configure_for_webapp(opts)
  end

  ENV['PGPASSWORD'] = ENV['DB_PASSWORD']
  target_file = opts[:target_file]
  target_file = "#{opts[:env]}_#{ENV['DB_DATABASE']}.sql" unless target_file
  cmd = "pg_dump --encoding utf8 --clean --if-exists -h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']} --file '#{target_file}'"
  verbose cmd
  exec(cmd)
end
