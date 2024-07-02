# frozen_string_literal: true

DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  config.log_only = false

  # Whether to use ActiveJob or dispatch events immediately.
  #
  config.async = true

  # Which ActiveJob queue to put events on
  #
  config.queue = :low_priority

  # The name of the BigQuery table we're writing to.
  #
  config.bigquery_table_name = Settings.google.bigquery.table_name

  # The name of the BigQuery project we're writing to.
  #
  config.bigquery_project_id = Settings.google.bigquery.project_id

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = Settings.google.bigquery.dataset

  # Enables the EntityTableCheckJob
  #
  config.entity_table_checks_enabled = true

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  config.enable_analytics = proc { FeatureService.enabled?(:send_request_data_to_bigquery) }

  # The environment we're running in. This value will be attached
  # to all events we send to BigQuery.
  #
  # config.environment = ENV.fetch('RAILS_ENV', 'development')

  # Whether to use azure workload identity federation for authentication
  # instead of the BigQuery API JSON Key. Note that this also will also
  # use a new version of the BigQuery streaming APIs.
  config.azure_federated_auth = true
end
