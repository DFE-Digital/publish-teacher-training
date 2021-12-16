require "English"
desc "Lint ruby code"
namespace :lint do
  task ruby: :environment do
    puts "Linting..."
    unless system "bundle exec rubocop app config db lib spec Gemfile --format clang -a"
      exit $CHILD_STATUS.exitstatus
    end
  end
end
