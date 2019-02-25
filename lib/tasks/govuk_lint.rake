desc "Lint ruby code"
namespace :lint do
  task :ruby do
    puts 'Linting...'
    system 'bundle exec govuk-lint-ruby app config db lib spec Gemfile --format clang -a'
  end
end
