# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "simplecov"
require_relative "config/application"

Rails.application.load_tasks

task lint: ["lint:ruby"]
task annotate: ["db:annotate"]
task parallel: ["parallel:spec"]
task default: %i[parallel annotate lint brakeman]
