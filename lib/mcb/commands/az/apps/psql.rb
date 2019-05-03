name 'psql'
summary 'connect to the psql server for an app'

instance_eval(&MCB.remote_connect_options)

run do |opts, _args, _cmd|
  if MCB.requesting_remote_connection? opts
    MCB::Azure.configure_for_webapp(opts)
  end

  ENV['PGPASSWORD'] = ENV['DB_PASSWORD']
  psql = "psql -h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']}"

  # could have used verbose() here, but it's worth being certain which psql server you are connected to
  puts psql

  exec(psql)
end
