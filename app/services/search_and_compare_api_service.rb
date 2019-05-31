module SearchAndCompareAPIService
  class Connection
    class << self
      def api
        Faraday.new(url: Settings.search_api.base_url) do |faraday|
          faraday.response :logger unless Rails.env.test?
          faraday.adapter Faraday.default_adapter
          faraday.headers['Content-Type'] = 'application/json; charset=utf-8;'
          faraday.headers['Authorization'] = "Bearer #{Settings.search_api.secret}"
        end
      end
    end
  end

  class Request
    class << self
      # NOTE:
      #   HTTP PUT "/api/courses" accepts a list of courses
      #   It will only add or update, no DELETION.
      def sync(course)
        response = api.put(
          "/api/courses/",
          serialize(course)
        )

        response.success?
      end

      def api
        Connection.api
      end

    private

      def serialize(payload)
        ActiveModel::Serializer::CollectionSerializer.new(
          payload,
          serializer: SearchAndCompare::CourseSerializer,
          adapter: ActiveModel::Serializer::Adapter::JsonApi
        ).to_json
      end
    end
  end
end
