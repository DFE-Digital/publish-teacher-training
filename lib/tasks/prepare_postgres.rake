desc "Prepare db for dev environments"
namespace :db do
  task create: [:prepare_postgres]

  task :prepare_postgres do
    if package_missing? 'postgres'
      case RUBY_PLATFORM
      when /darwin/
        darwin_install_package 'postgres'

      else
        puts <<~EOTEXT
          Don't know how to install postgres on your platform. Please do so yourself \
          before you proceed
        EOTEXT
      end
    end

    run_sql <<~EOSQL.strip
      CREATE USER manage_courses_backend WITH SUPERUSER CREATEDB PASSWORD 'manage_courses_backend';
    EOSQL
  end

  task :drop do
    Rake::Task['db:drop_dev_user'].execute
  end

  task :drop_dev_user do
    run_sql <<~EOSQL.strip
      DROP ROLE IF EXISTS manage_courses_backend;
    EOSQL
  end

private

  def run_sql(query)
    case RUBY_PLATFORM
    when /darwin/
      system('psql', '-c', query)
    when /linux/
      system('sudo', '-u', 'postgres', 'psql', '-c', query)
    else
      puts <<~EOTEXT
        Don't know how to support this platform, sorry. Please run this SQL in psql by hand:

        #{query}
      EOTEXT
    end
  end

  def package_missing?(package)
    command = 'which ' + package

    `#{command}`[0] != '/'
  end

  def darwin_install_package(package)
    system('brew', 'install', package)
  end
end
