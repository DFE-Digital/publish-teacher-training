desc "Annotate models, routes and serializers"
namespace :db do
  task 'schema:load' => [:annotate]
  task :annotate do
    puts 'Annotating models...'
    system 'bundle exec annotate -r'
  end
end
