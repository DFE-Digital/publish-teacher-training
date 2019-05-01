name 'set'
summary 'Set a config value'
usage 'set <key> <value>'
param :name
param :value

run do |_opts, args, _cmd|
  verbose "setting config #{args[:name]} to #{args[:value]}}"
  MCB.config[args[:name]] = args[:value]
  MCB.config.save
end
