LogStashLogger.configure do |config|
  config.customize_event do |event|
    event["application"] = Settings.application
    event["environment"] = Rails.env
  end
end
