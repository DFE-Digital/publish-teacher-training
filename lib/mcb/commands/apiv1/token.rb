name 'token'
summary 'Operate on the APIV1 token'
default_subcommand 'show'

option :A, 'webapp',
       'Connect to the database of this webapp',
       argument: :required
option :G, 'rgroup',
       'Use resource group for app (optional)',
       argument: :required
