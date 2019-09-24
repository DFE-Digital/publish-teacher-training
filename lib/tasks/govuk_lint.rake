desc "Lint ruby code"
namespace :lint do
  task :ruby do
    puts "Linting..."
    unless system "bundle exec rubocop app config db lib spec Gemfile --format clang -a"
      exit $?.exitstatus
    end
  end
end
