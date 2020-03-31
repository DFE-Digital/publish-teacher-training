LogStashLogger.configure do |config|
  commit_sha = File.read(Rails.root.join("COMMIT_SHA")).strip
  config.customize_event do |event|
    event["application"] = Settings.application
    event["environment"] = Rails.env
    event["release"] = commit_sha
  end
end
