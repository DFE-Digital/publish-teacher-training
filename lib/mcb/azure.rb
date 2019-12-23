module MCB
  module Azure
    @configs = {}

    def self.get_subs
      raw_json = MCB::run_command "az account list"
      JSON.parse(raw_json)
    end

    def self.get_apps
      raw_json = MCB::run_command "az webapp list"
      JSON.parse(raw_json)
    end

    def self.rgroup_for_app(app)
      MCB::Azure
        .get_apps
        .select { |s| s["name"] == app }
        .first
        .fetch("resourceGroup")
    rescue # rubocop: disable Style/RescueStandardError
      MCB::LOGGER.error("could not retrieve resource group for app #{app}, " \
                        "is this the right subscription?")
    end

    def self.get_config(webapp:, rgroup: nil, subscription: nil, **_opts)
      config_key = "#{subscription}-#{rgroup}-#{webapp}"
      unless @configs.key? config_key
        rgroup ||= rgroup_for_app(webapp)
        cmd = "az webapp config appsettings list -g \"#{rgroup}\" -n \"#{webapp}\""
        cmd += " --subscription \"#{subscription}\"" if subscription
        raw_json = MCB::run_command(cmd)
        @configs[config_key] = JSON.parse(raw_json)
                                 .map { |c| [c["name"], c["value"]] }
                                 .to_h
      end
      @configs[config_key]
    end

    def self.get_urls(webapp:, rgroup: nil, subscription: nil, **_opts)
      rgroup ||= rgroup_for_app(webapp)
      cmd = "az webapp config hostname list -g \"#{rgroup}\" --webapp-name \"#{webapp}\""
      cmd += " --subscription \"#{subscription}\"" if subscription
      raw_json = MCB::run_command(cmd)
      hostname_config = JSON.parse(raw_json)
      hostname_config.map do |conf|
        if conf["sslState"] == "SniEnabled"
          "https://#{conf['name']}"
        else
          "http://#{conf['name']}"
        end
      end
    end

    def self.configure_database(app_config)
      [%w[DB_HOSTNAME MANAGE_COURSES_POSTGRESQL_SERVICE_HOST],
       %w[DB_DATABASE PG_DATABASE],
       %w[DB_USERNAME PG_USERNAME],
       %w[DB_PASSWORD PG_PASSWORD]].each do |rails_env_var, csharp_env_var|
        ENV[rails_env_var] = app_config.fetch(rails_env_var) do
          app_config.fetch(csharp_env_var)
        end
      end
    end

    def self.configure_redis(app_config)
      %w[REDIS_URL SETTINGS__MCBG__REDIS_PASSWORD].each do |env_var|
        ENV[env_var] = app_config.fetch(env_var)
      end
    end

    def self.configure_env(app_config)
      ENV.update(
        app_config.select { |e| e.start_with?("SETTINGS__") },
      )
    end

    # Pull in the app config from Azure and prompt the user for the
    # RAILS_ENV to make sure they are running against the environment they
    # expect.
    #
    # We use keyword params here to accept the opts that are passed into
    # the commands.
    def self.configure_for_webapp(webapp:, rgroup: nil, subscription: nil, **_opts)
      # switch_to_subscription(opts[:subscription])
      rgroup ||= rgroup_for_app(webapp)
      app_config = MCB::Azure.get_config(webapp: webapp,
                                         rgroup: rgroup,
                                         subscription: subscription)

      # TODO: only require confirmation on commands that write to the db
      print "As a safety measure, please enter the expected RAILS_ENV for #{webapp}: "
      expected_environment = $stdin.readline.chomp

      if app_config["RAILS_ENV"] != expected_environment
        raise "RAILS_ENV for #{webapp} does not match: " \
              "#{app_config['RAILS_ENV']} != #{expected_environment}"
      end

      MCB::Azure.configure_database(app_config)
      MCB::Azure.configure_redis(app_config)
      MCB::Azure.configure_env(app_config)

      app_config["RAILS_ENV"]
    end
  end
end
