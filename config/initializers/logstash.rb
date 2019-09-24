LogStashLogger.configure do |config|
  config.customize_event do |event|
    event["application"] = Settings.application
    event["environment"] = Rails.env

    if Thread.current.key? :logstash
      if Thread.current[:logstash].key? :user_id
        event["user_id"] = Thread.current[:logstash][:user_id]
      end

      if Thread.current[:logstash].key? :sign_in_user_id
        event["sign_in_user_id"] = Thread.current[:logstash][:sin_in_user_id]
      end
    end
  end
end
