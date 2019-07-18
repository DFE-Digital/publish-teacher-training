name 'sites'
summary 'Operate on courses directly in db'

instance_eval(&MCB.remote_connect_options)

default_subcommand :list
