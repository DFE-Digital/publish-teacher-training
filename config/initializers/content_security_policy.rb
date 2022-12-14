# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://*.find-postgraduate-teacher-training.service.gov.uk", "https://*.publish-teacher-training-courses.service.gov.uk"
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self,
      :unsafe_inline, # Backwards compatibility; ignored by modern browsers as we set a nonce for scripts
      "https://*.find-postgraduate-teacher-training.service.gov.uk",
      "https://*.publish-teacher-training-courses.service.gov.uk",
      "https://www.google-analytics.com",
      "https://www.googletagmanager.com"

    policy.connect_src :self,
      "https://stats.g.doubleclick.net",
      "https://*.sentry.io",
      "https://*.google-analytics.com",
      "https://*.analytics.google.com"

    policy.style_src   :self,
      "https://*.find-postgraduate-teacher-training.service.gov.uk",
      "https://*.publish-teacher-training-courses.service.gov.uk"

    policy.frame_src   :self,
      "https://www.googletagmanager.com"

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end
  #
  #   # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
  #
  #   # Report CSP violations to a specified URI. See:
  #   # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
  #   # config.content_security_policy_report_only = true
end
