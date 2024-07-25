# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    local_domains = %w[https://publish.localhost https://find.localhost]
    prod_domains = [
      'https://*.find-teacher-training-courses.service.gov.uk',
      'https://*.find-postgraduate-teacher-training.service.gov.uk',
      'https://*.publish-teacher-training-courses.service.gov.uk'
    ]
    all_domains = local_domains + prod_domains

    policy.default_src :self
    policy.font_src    :self, :data, *all_domains
    policy.img_src     :self,
                       :https,
                       :data,
                       "https://#{Settings.google_tag_manager.floodlight_id}.fls.doubleclick.net" # Floodlight

    policy.object_src  :none
    policy.script_src  :self,
                       'https://www.google-analytics.com',
                       'https://www.googletagmanager.com',
                       "'sha256-aBGeCwtg0DKytYpKh9kIMvmYL0sooy9+McqPAZ5feTk='", # add_js_enabled_class_to_body.html.erb
                       *all_domains

    policy.connect_src :self,
                       'https://stats.g.doubleclick.net',
                       'https://*.sentry.io',
                       'https://*.google-analytics.com',
                       'https://*.analytics.google.com',
                       'https://www.google.com',
                       *all_domains

    policy.style_src   :self, *all_domains

    policy.frame_src   :self,
                       'https://www.googletagmanager.com',
                       "https://#{Settings.google_tag_manager.floodlight_id}.fls.doubleclick.net", # Floodlight
                       *local_domains

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
