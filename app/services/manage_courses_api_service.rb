module ManageCoursesAPIService
  class Connection
    def self.api
      Faraday.new(url: Settings.manage_api.base_url) do |faraday|
        faraday.response :logger unless Rails.env.test?
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{Settings.manage_api.secret}"
      end
    end
  end

  class Request
    class << self
      def sync_course_with_search_and_compare(email, provider_code, course_code)
        response = api.post(
          "/api/Publish/internal/course/#{provider_code}/#{course_code}",
          { email: email }.to_json
        )
        if response.success?
          JSON.parse(response.body)["result"]
        else
          false
        end
      end

      def sync_courses_with_search_and_compare(email, provider_code)
        response = api.post(
          "/api/Publish/internal/courses/#{provider_code}",
          { email: email }.to_json
        )

        if response.success?
          JSON.parse(response.body).fetch('result')
        else
          false
        end
      end

      def api
        Connection.api
      end
    end
  end
end
