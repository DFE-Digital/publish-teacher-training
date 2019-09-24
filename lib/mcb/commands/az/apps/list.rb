require "json"

name "list"
summary "list webapps in azure"

run do |_opts, _args, _cmd|
  apps = MCB::Azure.get_apps.map { |s| s.slice("name", "resourceGroup") }
  tp.set :max_width, 50
  tp apps
end
