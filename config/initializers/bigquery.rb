require "google/cloud/bigquery"

require_relative "../../app/services/feature_service"

if FeatureService.enabled?(:send_request_data_to_bigquery)
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = Settings.google.bigquery.project_id
    config.credentials = JSON.parse(Settings.google.bigquery.api_json_key)
  end

  Google::Cloud::Bigquery.new
end
