require 'json'

name 'config'
summary 'read webapp config from azure, requires app name and resource from `mcb az list`'
param :app
param :rgroup

run do |_opts, args, _cmd|
  app = args[:app]
  rgroup = args[:rgroup]
  puts Azure.get_config(app, rgroup)
end
