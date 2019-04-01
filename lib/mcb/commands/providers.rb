name 'provider'
summary 'Operate on providers directly in db'
default_subcommand 'list'

option nil, 'webapp',
       'Connect to the database of this webapp',
       argument: :required do |webapp|
  if webapp
    MCB::Azure.configure_database(webapp)
  end
end
