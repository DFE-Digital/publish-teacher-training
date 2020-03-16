namespace :db do
  namespace :seed do
    desc "Seed integration test data"
    task integration: :environment do
      require_relative "../../db/integration_seeds"
    end
  end
end
