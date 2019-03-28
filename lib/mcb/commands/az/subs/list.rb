name 'list'
summary 'list subscriptions in azure'

run do |_opts, args, _cmd|
  puts Azure.get_subs.map {|s| s["name"]}
end
