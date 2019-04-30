name 'course'
summary 'Operate on courses directly in db'

option :A, 'webapp',
       'Connect to the database of this webapp',
       argument: :required
option :G, 'rgroup',
       'Use resource group for app (optional)',
       argument: :required
