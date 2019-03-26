module ManageCoursesAPI
  class Connection
    BASE_URL = Settings.manage_api.base_url
    TOKEN = Settings.manage_api.secret

    def self.api
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.response :logger unless Rails.env.test?
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{TOKEN}"
      end
    end
  end

  class Request
    class << self
      def publish_course(email, provider_code, course_code)
        response = api.post("/api/Publish/internal/course/#{provider_code}/#{course_code}", email: email)
        if response.status == 200
          JSON.parse(response.body)["result"]
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
