name "console"
summary "Launch a rails console (useful for remote environments)"

instance_eval(&MCB.remote_connect_options)

run do |opts, _args, _cmd|
  MCB.rails_console(opts)
end
