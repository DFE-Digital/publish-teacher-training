# frozen_string_literal: true

module LoggerDouble
  def with_logger_double
    logger = Rails.logger
    logger_double = instance_double(Logger)
    Rails.logger = logger_double

    yield
  ensure
    Rails.logger = logger
  end
end
