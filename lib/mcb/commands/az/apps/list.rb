require 'json'

name 'list'
summary 'list webapps in azure'

run do |_opts, args, _cmd|
  puts MCB::Azure.get_apps.map {|s| {name: s["name"], resourceGroup: s["resourceGroup"]}}
end
