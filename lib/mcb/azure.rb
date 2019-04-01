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

    def self.get_config(app, rgroup)
      raw_json = MCB::run_command(
        "az webapp config appsettings list -g #{rgroup} -n #{app}"
      )
      config = JSON.parse(raw_json)
      config.map { |c| [c["name"], c["value"]] }.to_h
    end

    def self.configure_database(app)
      rgroup = MCB::Azure
                 .get_apps
                 .select { |s| s["name"] == app }
                 .first
                 .fetch('resourceGroup')
      app_config = MCB::Azure.get_config(app, rgroup)
      ENV['DB_HOSTNAME'] = app_config["MANAGE_COURSES_POSTGRESQL_SERVICE_HOST"]
      ENV['DB_DATABASE'] = app_config["PG_DATABASE"]
      ENV['DB_USERNAME'] = app_config["PG_USERNAME"]
      ENV['DB_PASSWORD'] = app_config["PG_PASSWORD"]
    end
  end
end
