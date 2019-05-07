name 'provider'
summary 'Operate on providers directly in db'
default_subcommand 'list'

instance_eval(&MCB.remote_connect_options)
