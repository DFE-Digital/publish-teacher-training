class LogStashFormatter < SemanticLogger::Formatters::Raw
  def format_json_message_context
    if hash[:message].present?
      context = JSON.parse(hash[:message])["context"]
      hash[:sidekiq_job_context] = hash[:message]
      hash[:message] = context
    end
  rescue JSON::ParserError
    nil
  end

  def format_exception
    exception_message = hash.dig(:exception, :message)
    if exception_message.present?
      hash[:message] = "Exception occured: #{exception_message}"
    end
  end

  def format_backtrace
    if hash[:message]&.start_with?("/")
      message_lines = hash[:message].split("\n")
      if message_lines.all? { |line| line.start_with?("/") }
        hash[:backtrace] = hash[:message]
        hash[:message] = "Exception occured: #{message_lines.first}"
      end
    end
  end

  # The value here appears to break logging to logstash / elasticsearch
  def format_duration
    hash[:duration] = hash[:duration_ms]
    hash[:duration_ms] = nil
  end

  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
  end

  def call(log, logger)
    super(log, logger)
    format_job_data
    format_duration
    format_exception
    format_json_message_context
    format_backtrace
    hash.to_json
  end
end

if Settings.logstash.host && Settings.logstash.port
  # For some reason logstash / elasticsearch drops events where the payload
  # is a hash. These are more conveniently accessed at the top level of the
  # event, anyway, so we move it there.
  fix_payload = Proc.new do |event|
    if event["payload"].present?
      event.append(event["payload"])
      event["payload"] = nil
    end
  end

  log_stash = LogStashLogger.new(Settings.logstash.to_h.merge(customize_event: fix_payload))
  SemanticLogger.add_appender(logger: log_stash, level: :info, formatter: LogStashFormatter.new)
elsif Rails.env.production?
  warn("logstash not configured, falling back to standard Rails logging")
end
