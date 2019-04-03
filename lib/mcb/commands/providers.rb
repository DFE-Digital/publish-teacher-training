name 'provider'
summary 'Operate on providers directly in db'
default_subcommand 'list'

option nil, 'webapp',
       'Connect to the database of this webapp',
       argument: :required do |webapp|
  app_config = MCB::Azure.get_config(webapp)

  # TODO: we should only require confirmation on commands that write to the db
  print "As a safety measure, please enter the expected RAILS_ENV for #{webapp}: "
  expected_environment = $stdin.readline.chomp

  if app_config['RAILS_ENV'] != expected_environment
    raise "RAILS_ENV for #{webapp} does not match: " \
          "#{app_config['RAILS_ENV']} != #{expected_environment}"
  end

  MCB::Azure.configure_database(webapp, app_config: app_config)
end
