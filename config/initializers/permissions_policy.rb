# frozen_string_literal: true

# Emit a Permissions-Policy header that restricts powerful browser features
# neither Find nor Publish use, per ITHC FF25-567.
#
# Rails' built-in `config.permissions_policy` DSL still emits the deprecated
# `Feature-Policy` header name with the old `camera 'none'` syntax, which
# does not satisfy the ITHC requirement. We set the modern header via
# ActionDispatch default_headers instead.
#
# "geolocation" here refers to the browser API — the app's own geolocation
# features are server-side Google Geocoding calls and are unaffected.

Rails.application.config.action_dispatch.default_headers["Permissions-Policy"] = [
  "camera=()",
  "microphone=()",
  "geolocation=()",
  "gyroscope=()",
  "magnetometer=()",
  "usb=()",
  "payment=()",
  "fullscreen=(self)",
].join(", ")
