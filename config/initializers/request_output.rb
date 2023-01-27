# frozen_string_literal: true

if Rails.env.development?
  require 'rack/request_output'

  Rails.application.config.middleware.insert_after Sentry::Rails::CaptureExceptions, Rack::RequestOutput
end
