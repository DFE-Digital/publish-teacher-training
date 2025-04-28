# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    all_domains = [*Settings.find_hosts, *Settings.publish_hosts, *Settings.api_hosts]

    policy.default_src :self
    policy.font_src    :self, :data, "fonts.googleapis.com", *all_domains
    policy.img_src     :self,
                       :https,
                       :data

    policy.object_src  :none
    policy.script_src  :self,
                       "'sha256-aBGeCwtg0DKytYpKh9kIMvmYL0sooy9+McqPAZ5feTk='", # add_js_enabled_class_to_body.html.erb
                       *all_domains

    policy.connect_src :self,
                       "https://*.sentry.io",
                       "https://www.google.com",
                       *all_domains

    policy.style_src   :self, *all_domains

    policy.frame_src   :self,
                       *all_domains

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
end
