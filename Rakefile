# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "simplecov"
require_relative "config/application"

task default: []

Rails.application.load_tasks
Rake::Task["default"].clear

task lint: %w[lint:ruby lint:erb]
task parallel: ["parallel:spec"]
task default: %i[lint parallel brakeman]
