# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    desc "Run db:migrate:with_data if environment is staging or production or just db:migrate and ignore ActiveRecord::ConcurrentMigrationError errors"
    task with_data_migrations: :environment do
      if %w[staging production].include?(Rails.env)
        Rake::Task["db:migrate:with_data"].invoke
      else
        Rake::Task["db:migrate"].invoke
      end

    rescue ActiveRecord::ConcurrentMigrationError
      # Do nothing
    end
  end
end
