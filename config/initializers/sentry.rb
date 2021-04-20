Sentry.init do |config|
  # Let’s not exclude ActiveRecord::RecordNotFound from Sentry
  # https://github.com/DFE-Digital/teacher-training-api/pull/160
  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    filter.filter(event.to_hash)
  end

  config.release = ENV["COMMIT_SHA"]

  # https://docs.sentry.io/platforms/ruby/configuration/sampling/#configuring-the-transaction-sample-rate
  config.traces_sampler = lambda do |sampling_context|
    transaction = sampling_context[:transaction_context]

    if transaction[:name].start_with? "/ping"
      # Ping event isn't worth tracking.
      false
    elsif transaction[:name].match? %r{/api/public/v1/recruitment_cycles/\d+/providers/\w+/courses/\w+/locations}
      # 85% of our traffic appears to be to the locations controller (about
      # 30tpm!). Probably worth investigating in it's own right, but for now
      # we need to throttle these down.
      #
      # At 85% of 400k/day this gives us ~340/day or ~20,000/month.
      0.002
    else
      # At 15% of 400k/day this gives us ~1200/day or ~36,000/month.
      0.02
    end
  end
end
