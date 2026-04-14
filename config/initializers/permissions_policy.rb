# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Restrict powerful browser features that neither Find nor Publish use, per
# ITHC FF25-567 (see guides/ithc-ff25-567-remediation.md). Geolocation here
# refers to the browser API — the app's own geolocation features are
# server-side Google Geocoding calls and are unaffected.
Rails.application.config.permissions_policy do |policy|
  policy.camera       :none
  policy.microphone   :none
  policy.geolocation  :none
  policy.gyroscope    :none
  policy.magnetometer :none
  policy.usb          :none
  policy.payment      :none
  policy.fullscreen   :self
end
