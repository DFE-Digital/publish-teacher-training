desc "Prepare db for dev environments"
namespace :db do
  task create: [:create_dev_role]

  task :create_dev_role do
    if exec_present? 'createuser'
      system "createuser -d -s -w #{username}"
      puts "Created user '#{username}'"
    else
      puts <<~EOTEXT
        No 'createuser' command. Please ensure postgres is installed:

        For OSX, use brew:

          brew install postgresql

        For Linux, use your package manager. e.x. for Debian/Ubunte:

          apt-get install postgresql

      EOTEXT
    end
  end

  task :add_password_to_dev_role do
    run_sql <<~EOSQL.strip
      ALTER USER #{username} WITH PASSWORD '#{password}';
    EOSQL
    puts "Changed password for user '#{username}'"
  end

  task :drop do
    Rake::Task['db:drop_dev_role'].execute
  end

  task :drop_dev_role do
    system("dropuser #{username}")
    puts "Dropped user '#{username}'"
  end

private

  def run_sql(query)
    case RUBY_PLATFORM
    when /darwin/
      system('psql', '-c', query, dbname)
    when /linux/
      system('sudo', '-u', 'postgres', 'psql', '-c', query, dbname)
    else
      puts <<~EOTEXT
        Don't know how to support this platform, sorry. Please run this SQL in psql by hand:

        #{query}
      EOTEXT
    end
  end

  def exec_present? name
    system("which #{name} 2>&1 >/dev/null")
  end

  def darwin_install_package(package)
    system('brew', 'install', package)
  end

  def dbname
    Rails.application.config.database_configuration.fetch(Rails.env).fetch('database')
  end

  def username
    Rails.application.config.database_configuration.fetch(Rails.env).fetch('username')
  end

  def password
    Rails.application.config.database_configuration.fetch(Rails.env).fetch('password')
  end
end

Rake::Task['db:create'].enhance do
  Rake::Task['db:add_password_to_dev_role'].invoke
end
