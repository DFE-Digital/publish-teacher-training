# frozen_string_literal: true

# Emit a Permissions-Policy header that restricts powerful browser features
# neither Find nor Publish use, per ITHC FF25-567.
#
# Rails' built-in `config.permissions_policy` DSL still emits the deprecated
# `Feature-Policy` header name with the old `camera 'none'` syntax
# (see actionpack lib/action_dispatch/http/permissions_policy.rb), which
# does not satisfy the ITHC requirement. We set the modern header directly
# via a small Rack middleware instead.
#
# "geolocation" here refers to the browser API — the app's own geolocation
# features are server-side Google Geocoding calls and are unaffected.

module PermissionsPolicyHeader
  HEADER_NAME = "Permissions-Policy"
  HEADER_VALUE = [
    "camera=()",
    "microphone=()",
    "geolocation=()",
    "gyroscope=()",
    "magnetometer=()",
    "usb=()",
    "payment=()",
    "fullscreen=(self)",
  ].join(", ").freeze

  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers[HEADER_NAME] ||= HEADER_VALUE
      [status, headers, body]
    end
  end
end

Rails.application.config.middleware.use PermissionsPolicyHeader::Middleware
