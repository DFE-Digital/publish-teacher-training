# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    desc "Run db:migrate:with_data if environment is staging or production or just db:migrate and ignore ActiveRecord::ConcurrentMigrationError errors"
    task with_data_migrations: :environment do
      Rake::Task["db:migrate:with_data"].invoke
    rescue ActiveRecord::ConcurrentMigrationError
      # Do nothing
    end
  end
end
