if Rails.env.development? || Rails.env.production?
  Rails.application.configure do
    config.semantic_logger.application = Settings.application_name
    config.log_tags = [:request_id]
    config.log_level = Settings.log_level
  end
  SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
  Rails.application.config.logger.info("Application logging to STDOUT")
end
