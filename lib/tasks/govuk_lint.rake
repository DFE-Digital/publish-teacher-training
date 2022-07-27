require "English"
desc "Lint ruby code"
namespace :lint do
  desc "Lint Ruby code"
  task ruby: :environment do
    puts "Linting ruby..."
    system("bundle exec rubocop app config db lib spec Gemfile --format clang") || exit($CHILD_STATUS.exitstatus)
  end

  desc "Lint erb files"
  task erb: :environment do
    puts "Linting erb files..."
    system("bundle exec erblint app") || exit($CHILD_STATUS.exitstatus)
  end

  desc "Lint javascript files"
  task js: :environment do
    puts "Linting javascript files..."
    system("yarn run standard:fix") || exit($CHILD_STATUS.exitstatus)
  end
end
