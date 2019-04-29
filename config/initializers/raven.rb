# coding: utf-8

Raven.configure do |config|
  # Let’s not exclude ActiveRecord::RecordNotFound from Sentry
  # https://github.com/getsentry/raven-ruby/wiki/Advanced-Configuration#excluding-exceptions
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT -
    ['ActiveRecord::RecordNotFound']

  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
