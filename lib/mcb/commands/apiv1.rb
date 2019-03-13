name 'apiv1'
summary 'Commands that target the V1 providers endpoint'

option :u, 'url', 'set the url to connect to',
       argument: :required,
       default: 'http://localhost:3001/api/v1/2019/providers'
option :t, 'token', 'set the authorization token',
       argument: :required,
       default: 'bats'
