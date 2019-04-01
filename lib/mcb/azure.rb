module Azure
  def self.get_subs
    cmd = "az account list"
    verbose(cmd)
    raw_json = `#{cmd}`
    JSON.parse(raw_json)
  end

  def self.get_apps
    cmd = "az webapp list"
    verbose(cmd)
    raw_json = `#{cmd}`
    JSON.parse(raw_json)
  end

  def self.get_config(app, rgroup)
    cmd = "az webapp config appsettings list -g #{rgroup} -n #{app}"
    verbose(cmd)
    raw_json = `#{cmd}`
    config = JSON.parse(raw_json)
    config.map{|c| k,v = [c["name"],c["value"]]}.to_h
  end

  def self.configure_database(app)
    rgroup = Azure.get_apps.select {|s| s["name"] == app}[0]["resourceGroup"]
    app_config = Azure.get_config(app, rgroup)
    ENV['DB_HOSTNAME'] = app_config["MANAGE_COURSES_POSTGRESQL_SERVICE_HOST"]
    ENV['DB_DATABASE'] = app_config["PG_DATABASE"]
    ENV['DB_USERNAME'] = app_config["PG_USERNAME"]
    ENV['DB_PASSWORD'] = app_config["PG_PASSWORD"]
  end
end
