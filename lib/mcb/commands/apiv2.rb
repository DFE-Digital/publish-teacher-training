name 'apiv2'
summary 'Commands that target the V2 endpoint'

option :u, 'url', 'set the base url to connect to',
       argument: :required,
       default: 'http://localhost:3001/api/v2'
option :t, 'token', 'set the authorization token',
       argument: :required,
       default: 'bats'
instance_eval(&MCB.remote_connect_options)
