# frozen_string_literal: true

module PublishPublicAPI
  # Reads courses, their locations and providers from the public Publish API
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
      data = []

      each_page(path, year:, include: "recruitment_cycle", filter: { findable: true }) { |body| data.concat(body["data"]) }

      data
    end

    # Findable courses the provider accredits and someone else runs, grouped by
    # the code of the provider that runs them. The API can't filter by
    # accredited provider, so this reads the whole cycle.
    def accredited_courses(year:, accredited_provider_code:)
      partners = Hash.new { |hash, code| hash[code] = [] }

      each_page("recruitment_cycles/#{year}/courses", year:, include: "provider,recruitment_cycle", filter: { findable: true }) do |body|
        provider_codes = included(body, "providers").to_h { |provider| [provider["id"], provider.dig("attributes", "code")] }

        body["data"].each do |course|
          next unless course.dig("attributes", "accredited_body_code") == accredited_provider_code

          provider_code = provider_codes.fetch(course.dig("relationships", "provider", "data", "id"))
          partners[provider_code] << course unless provider_code == accredited_provider_code
        end
      end

      partners.to_h
    end

    def provider(year:, provider_code:)
      get("recruitment_cycles/#{year}/providers/#{provider_code}").dig("data", "attributes")
    end

    # For a course published without schools of its own, the API returns the
    # provider's schools instead and says so with meta.has_course_schools.
    def course_locations(year:, provider_code:, course_code:)
      body = get("recruitment_cycles/#{year}/providers/#{provider_code}/courses/#{course_code}/locations")
      return [] if body.dig("meta", "has_course_schools") == false

      body["data"]
    end

  private

    # Follows links.next rather than meta.count: the cycle's /courses caches
    # its count per year whatever the filter, so the count can be wrong.
    def each_page(path, year:, **params)
      body = get(path, **params, page: 1, per_page: PER_PAGE)

      loop do
        assert_cycle!(body, year)
        yield body

        next_page = body.dig("links", "next")
        break if next_page.blank?

        body = @connection.get(next_page).body
      end
    end

    # The API falls back to the current cycle when it doesn't know the year asked for.
    def assert_cycle!(body, year)
      years = included(body, "recruitment_cycles").map { |resource| resource.dig("attributes", "year").to_i }

      if years.empty? && body["data"].any?
        raise Error, "Asked for the #{year} cycle but the API didn't say which cycle it returned"
      end

      return if years.all?(year)

      raise Error, "Asked for the #{year} cycle but the API returned #{years.uniq.join(', ')}"
    end

    def included(body, type)
      Array(body["included"]).select { |resource| resource["type"] == type }
    end

    def get(path, **params)
      @connection.get(path, params).body
    end
  end
end
