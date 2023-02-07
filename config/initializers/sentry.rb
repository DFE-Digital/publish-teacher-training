# frozen_string_literal: true

PG_DETAIL_REGEX = /^DETAIL:.*$/
PG_DETAIL_FILTERED = '[PG DETAIL FILTERED]'

def filter_record_not_unique_exception_messages!(event, hint)
  return unless hint[:exception].is_a?(ActiveRecord::RecordNotUnique)

  event.exception.values.each do |single_exception| # rubocop:disable Style/HashEachMethods
    single_exception.value.gsub!(PG_DETAIL_REGEX, PG_DETAIL_FILTERED)
  end
end

Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, hint|
    filter_record_not_unique_exception_messages!(event, hint)
    filter.filter(event.to_hash)
  end

  config.release = ENV.fetch('COMMIT_SHA', nil)

  config.excluded_exceptions += %w[
    ActiveRecord::RecordNotFound
    Pundit::NotAuthorizedError
  ]
end
