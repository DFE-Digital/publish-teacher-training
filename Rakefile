# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if %w[development test].include? Rails.env
  task lint: %w[lint:ruby lint:erb]
  task parallel: ["parallel:spec"]
  task :javascript_specs do
    system "yarn run test"
  end

  task(:default).clear
  task default: %i[lint spec brakeman javascript_specs]
end
