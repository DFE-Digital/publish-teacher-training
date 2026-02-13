# frozen_string_literal: true

# Docs: https://docs.sentry.io/platforms/ruby/guides/rails/configuration/filtering/
PG_DETAIL_REGEX = /^DETAIL:.*$/
PG_DETAIL_FILTERED = "[PG DETAIL FILTERED]"

def filter_record_not_unique_exception_messages!(event, hint)
  return unless hint[:exception].is_a?(ActiveRecord::RecordNotUnique)

  event.exception.each_value do |single_exception|
    single_exception.value.gsub!(PG_DETAIL_REGEX, PG_DETAIL_FILTERED)
  end
end

Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

  config.before_send = lambda do |event, _hint|
    filter_record_not_unique_exception_messages!(event, hint)

    # Sanitize extra data
    if event.extra
      event.extra = filter.filter(event.extra)
    end
    # Sanitize user data
    if event.user
      event.user = filter.filter(event.user)
    end
    # Sanitize context data (if present)
    if event.contexts
      event.contexts = filter.filter(event.contexts)
    end

    # Return the sanitized event object
    event
  end

  config.release = ENV.fetch("COMMIT_SHA", nil)

  config.excluded_exceptions += %w[
    ActiveRecord::RecordNotFound
    Pundit::NotAuthorizedError
  ]
end
