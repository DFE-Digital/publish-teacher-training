# frozen_string_literal: true

module FindAndUseAnAPI
  class Client
    class Rejected < StandardError; end

    def initialize(base_url: Settings.fauapi.base_url, api_key: Settings.fauapi.api_key)
      @connection = Faraday.new(base_url, headers: { "Authorization" => "Bearer #{api_key}" }) do |f|
        f.request :json
        f.response :raise_error
        f.response :json
        f.response :logger, Rails.logger, headers: false, bodies: false
      end
    end

    def import(manifest)
      request { @connection.post("api/tasks/apis/import", manifest) }
    end

    def list_apis
      request { @connection.get("api/tasks/apis") }
    end

    def publish(id)
      request { @connection.put("api/tasks/apis/#{id}/publish") }
    end

  private

    def request
      yield.body
    rescue Faraday::ClientError => e
      raise Rejected, "#{e.response_status} #{e.response_body}"
    end
  end
end
