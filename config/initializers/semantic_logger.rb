if Settings.logstash.host && Settings.logstash.port
  logstash_formatter = Proc.new do |event|
    # The value here appears to break logging to logstash / elasticsearch
    event["duration"] = event["duration_ms"]
    event["duration_ms"] = nil

    # For some reason logstash / elasticsearch drops events where the payload
    # is a hash. These are more conveniently accessed at the top level of the
    # event, anyway, so we move it there.
    if event["payload"].present?
      event.append(event["payload"])
      event["payload"] = nil
    end
  end

  log_stash = LogStashLogger.new(Settings.logstash.to_h.merge(customize_event: logstash_formatter))
  SemanticLogger.add_appender(logger: log_stash, level: :info, formatter: :json)
end
