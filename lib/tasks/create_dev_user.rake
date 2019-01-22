desc "Create user for dev environments"
namespace :db do
  def run_sql sql
    case RUBY_PLATFORM
    when /darwin/
      system('psql', '-U', 'postgres', '-c', sql)
    when /linux/
      system('sudo', '-u', 'postgres', 'psql', '-c', sql)
    else
      puts <<~EOT
        Don't know how to support this platform, sorry. Please run this SQL in psql by hand:

          #{sql}

        Patches for automating this are welcome.
      EOT
    end
  end

  task create: [:create_dev_user]
  task :drop do
    Rake::Task['db:drop_dev_user'].execute
  end

  task :create_dev_user do
    run_sql <<~EOSQL.strip
      CREATE USER manage_courses_backend WITH SUPERUSER CREATEDB PASSWORD 'manage_courses_backend';
    EOSQL
  end

  task :drop_dev_user do
    run_sql <<~EOSQL.strip
      DROP ROLE IF EXISTS manage_courses_backend;
    EOSQL
  end
end
