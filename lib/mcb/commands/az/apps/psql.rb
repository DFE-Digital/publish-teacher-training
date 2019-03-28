name 'psql'
summary 'connect to the psql server for an app'
param :app

run do |_opts, args, _cmd|
  Azure.configure_database(args[:app])

  ENV["PGPASSWORD"]= ENV['DB_PASSWORD']
  psql = "psql -h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']}"

  # could have used verbose() here, but it's worth being certain which psql server you are connected to
  puts psql

  exec(psql)
end
