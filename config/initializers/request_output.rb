if Rails.env.development?
  require "rack/request_output"

  Rails.application.config.middleware.insert_after Raven::Rack, Rack::RequestOutput
end
