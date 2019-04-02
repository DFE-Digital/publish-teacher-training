name 'list'
summary 'list subscriptions in azure'

run do |_opts, _args, _cmd|
  subs = MCB::Azure.get_subs.map { |s| s["name"] }
  puts subs
end
