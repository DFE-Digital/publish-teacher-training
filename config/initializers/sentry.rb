Sentry.init do |config|
  # Let’s not exclude ActiveRecord::RecordNotFound from Sentry
  # https://github.com/DFE-Digital/publish-teacher-training/pull/160
  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    filter.filter(event.to_hash)
  end

  config.release = ENV.fetch("COMMIT_SHA", nil)
end
