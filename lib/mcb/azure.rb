module MCB
  module Azure
    def self.get_subs
      raw_json = MCB::run_command 'az account list'
      JSON.parse(raw_json)
    end

    def self.get_apps
      raw_json = MCB::run_command 'az webapp list'
      JSON.parse(raw_json)
    end

    def self.rgroup_for_app(app)
      MCB::Azure
        .get_apps
        .select { |s| s["name"] == app }
        .first
        .fetch('resourceGroup')
    rescue # rubocop: disable Style/RescueStandardError
      MCB::LOGGER.error("could not retrieve resource group for app #{app}, " \
                        "is this the right subscription?")
    end

    def self.get_config(app, rgroup: nil)
      rgroup ||= rgroup_for_app(app)
      raw_json = MCB::run_command(
        "az webapp config appsettings list -g #{rgroup} -n #{app}"
      )
      config = JSON.parse(raw_json)
      config.map { |c| [c["name"], c["value"]] }.to_h
    end

    def self.configure_database(app, app_config: nil)
      app_config ||= MCB::Azure.get_config(app)
      ENV['DB_HOSTNAME'] = app_config["MANAGE_COURSES_POSTGRESQL_SERVICE_HOST"]
      ENV['DB_DATABASE'] = app_config["PG_DATABASE"]
      ENV['DB_USERNAME'] = app_config["PG_USERNAME"]
      ENV['DB_PASSWORD'] = app_config["PG_PASSWORD"]

    # Pull in the app config from Azure and prompt the user for the
    # RAILS_ENV to make sure they are running against the environment they
    # expect.
    #
    # We use keyword params here to accept the opts that are passed into
    # the commands.
    def self.configure_for_webapp(webapp:, rgroup: nil, **_opts)
      rgroup ||= rgroup_for_app(webapp)
      app_config = MCB::Azure.get_config(webapp, rgroup: rgroup)

      # TODO: only require confirmation on commands that write to the db
      print "As a safety measure, please enter the expected RAILS_ENV for #{webapp}: "
      expected_environment = $stdin.readline.chomp

      if app_config['RAILS_ENV'] != expected_environment
        raise "RAILS_ENV for #{webapp} does not match: " \
              "#{app_config['RAILS_ENV']} != #{expected_environment}"
      end

      MCB::Azure.configure_database(webapp, app_config: app_config)
    end
  end
end
