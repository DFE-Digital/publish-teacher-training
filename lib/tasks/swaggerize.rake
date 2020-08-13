if defined?(RSpec)
  require "rspec/core/rake_task"

  Rake::Task["rswag:specs:swaggerize"].clear

  namespace :rswag do
    namespace :specs do
      desc "Generate Swagger JSON files from integration specs"
      RSpec::Core::RakeTask.new("swaggerize") do |t|
        t.pattern = "spec/docs/**/*_spec.rb"

        t.rspec_opts = ["--format OpenApi::Rswag::Specs::SwaggerFormatter", "--dry-run", "--order defined"]
      end
    end
  end
end
