name 'user'
summary 'Operate on users directly in the db'
default_subcommand 'list'

instance_eval(&MCB.remote_connect_options)
