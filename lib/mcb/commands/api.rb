name "api"
summary "Commands that target the system API endpoint"

option :u, :url, "set the base url to connect to",
       argument: :required,
       default: "http://localhost:3001"
option :t, "token", "set the authorization token",
       argument: :required,
       default: "Ge32"
instance_eval(&MCB.remote_connect_options)
