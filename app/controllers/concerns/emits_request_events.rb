module EmitsRequestEvents
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    after_action :trigger_request_event
  end

  def trigger_request_event
    if FeatureService.enabled?(:send_request_data_to_bigquery)
      request_event = BigQuery::RequestEvent.new do |event|
        event.with_request_details(request)
        event.with_response_details(response)
        event.with_user(current_user)
      end

      SendEventToBigQueryJob.perform_later(request_event.as_json)
    end
  end
end
