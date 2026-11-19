# frozen_string_literal: true

module PublishPublicAPI
  # Reads courses and their locations from the public Publish API
  # (production by default). Returns the raw JSON:API resource hashes.
  class Client
    BASE_URL = "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1/"
    PER_PAGE = 500

    Error = Class.new(StandardError)

    def initialize(base_url: BASE_URL)
      @connection = Faraday.new(base_url) do |f|
        f.response :raise_error
        f.response :json
      end
    end

    def courses(year:, provider_code:)
      path = "recruitment_cycles/#{year}/providers/#{provider_code}/courses"

      fetch_all_pages(path, year:, include: "recruitment_cycle", filter: { findable: true })
    end

    def course_locations(year:, provider_code:, course_code:)
      get("recruitment_cycles/#{year}/providers/#{provider_code}/courses/#{course_code}/locations")["data"]
    end

  private

    def fetch_all_pages(path, year:, **params)
      data = []

      (1..).each do |page|
        body = get(path, **params, page:, per_page: PER_PAGE)
        assert_cycle!(body, year)
        data.concat(body["data"])

        break if body["data"].empty? || data.size >= body.dig("meta", "count").to_i
      end

      data
    end

    # The API falls back to the current cycle when it doesn't know the year asked for.
    def assert_cycle!(body, year)
      years = Array(body["included"])
        .select { |resource| resource["type"] == "recruitment_cycles" }
        .map { |resource| resource.dig("attributes", "year").to_i }

      if years.empty? && body["data"].any?
        raise Error, "Asked for the #{year} cycle but the API didn't say which cycle it returned"
      end

      return if years.all?(year)

      raise Error, "Asked for the #{year} cycle but the API returned #{years.uniq.join(', ')}"
    end

    def get(path, **params)
      @connection.get(path, params).body
    end
  end
end
