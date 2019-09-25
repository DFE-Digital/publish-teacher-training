require "json"

name "config"
summary "read webapp config from azure, requires app name and resource from `mcb az list`"
param :app
param :rgroup

run do |_opts, args, _cmd|
  app = args[:app]
  rgroup = args[:rgroup]
  puts MCB::Azure.get_config(webapp: app, rgroup: rgroup)
end
