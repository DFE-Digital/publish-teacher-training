name 'psql'
summary 'connect to the psql server for an app'

option :A, 'webapp',
       'Connect to the database of this webapp',
       argument: :required
option :G, 'rgroup',
       'Use resource group for app (can be auto-discovered)',
       argument: :required

run do |opts, _args, _cmd|
  MCB::Azure.configure_for_webapp(opts) if opts.key? :webapp

  ENV['PGPASSWORD'] = ENV['DB_PASSWORD']
  psql = "psql -h #{ENV['DB_HOSTNAME']} -U #{ENV['DB_USERNAME']} -d #{ENV['DB_DATABASE']}"

  # could have used verbose() here, but it's worth being certain which psql server you are connected to
  puts psql

  exec(psql)
end
