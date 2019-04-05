name 'provider'
summary 'Operate on providers directly in db'
default_subcommand 'list'

option :A, 'webapp',
       'Connect to the database of this webapp',
       argument: :required
option :G, 'rgroup',
       'Use resource group for app (can be auto-discovered)',
       argument: :required
