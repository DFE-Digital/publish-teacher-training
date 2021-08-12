module BigQuery
  class RequestEvent
    def initialize
      @event_hash = {
        environment: ENV["RAILS_ENV"],
        occurred_at: Time.zone.now.iso8601,
        event_type: "web_request",
      }
      yield self if block_given?
    end

    delegate :as_json, to: :event_hash

    def with_request_details(request)
      event_hash.merge!(
        request_uuid: request.uuid,
        request_path: request.path,
        request_method: request.method,
        request_user_agent: request.user_agent,
        request_query: query_to_kv_pairs(request.query_string),
        request_referer: request.referer,
        anonymised_user_agent_and_ip: anonymised_user_agent_and_ip(request),
      )
    end

    def with_response_details(response)
      event_hash.merge!(
        response_content_type: response.content_type,
        response_status: response.status,
      )
    end

    def with_user(user)
      event_hash.merge!(
        user_id: user&.id,
      )
    end

  private

    attr_reader :event_hash

    def query_to_kv_pairs(query_string)
      vars = Rack::Utils.parse_query(query_string)
      vars.map { |k, v| { "key" => k, "value" => [v].flatten } }
    end

    def anonymised_user_agent_and_ip(rack_request)
      if rack_request.remote_ip.present?
        anonymise(rack_request.user_agent.to_s + rack_request.remote_ip.to_s)
      end
    end

    def anonymise(text)
      Digest::SHA2.hexdigest(text)
    end
  end
end
