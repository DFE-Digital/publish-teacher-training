Rails.application.config.semantic_logger.application = Settings.application_name
Rails.application.config.rails_semantic_logger.format = :json
SemanticLogger.add_appender(io: STDOUT, level: Rails.application.config.log_level, formatter: Rails.application.config.rails_semantic_logger.format)
Rails.application.config.logger.info("Application logging to STDOUT")
