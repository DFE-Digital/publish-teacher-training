# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  config.content_security_policy do |policy|
    local_domains = %w[https://publish.localhost https://find.localhost]
    prod_domains = [
      'https://*.find-postgraduate-teacher-training.service.gov.uk',
      'https://*.publish-teacher-training-courses.service.gov.uk'
    ]
    all_domains = local_domains + prod_domains

    policy.default_src :self
    policy.font_src    :self, :data, *all_domains
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self,
                       'https://www.google-analytics.com',
                       'https://www.googletagmanager.com',
                       *all_domains

    policy.connect_src :self,
                       'https://stats.g.doubleclick.net',
                       'https://*.sentry.io',
                       'https://*.google-analytics.com',
                       'https://*.analytics.google.com',
                       *all_domains

    policy.style_src   :self, *all_domains

    policy.frame_src   :self, 'https://www.googletagmanager.com', *local_domains

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
