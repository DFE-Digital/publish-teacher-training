class SendEventToBigQueryJob < ApplicationJob
  queue_as :low_priority
  self.logger = ActiveSupport::TaggedLogging.new(Logger.new(IO::NULL))

  def perform(event_json, dataset = Settings.google.bigquery.dataset, table = Settings.google.bigquery.table_name)
    return unless FeatureService.enabled?(:send_request_data_to_bigquery)

    bq = Google::Cloud::Bigquery.new
    dataset = bq.dataset(dataset, skip_lookup: true)
    bq_table = dataset.table(table, skip_lookup: true)
    bq_table.insert([event_json])
  end
end
