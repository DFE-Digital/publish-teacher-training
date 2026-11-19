# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublishPublicAPI::Client do
  subject(:client) { described_class.new(base_url: "https://publish.test/api/public/v1/") }

  let(:courses_url) { "https://publish.test/api/public/v1/recruitment_cycles/2027/providers/C55/courses" }

  def course(code)
    {
      "id" => code.downcase,
      "type" => "courses",
      "attributes" => { "code" => code },
      "relationships" => { "recruitment_cycle" => { "data" => { "type" => "recruitment_cycles", "id" => "73" } } },
    }
  end

  def courses_page(codes, count:, year: 2027)
    {
      "data" => codes.map { |code| course(code) },
      "included" => [{ "id" => "73", "type" => "recruitment_cycles", "attributes" => { "year" => year } }],
      "meta" => { "count" => count },
    }.to_json
  end

  def stub_courses_page(page, body)
    stub_request(:get, courses_url)
      .with(query: { "filter" => { "findable" => "true" }, "include" => "recruitment_cycle", "page" => page.to_s, "per_page" => "500" })
      .to_return(status: 200, body:, headers: { "Content-Type" => "application/json" })
  end

  describe "#courses" do
    # Only courses findable in production: the stubs only answer when the filter is sent.
    it "returns the provider's findable courses for the cycle" do
      stub_courses_page(1, courses_page(%w[RX41 2B9P], count: 2))

      courses = client.courses(year: 2027, provider_code: "C55")

      expect(courses.map { |c| c.dig("attributes", "code") }).to eq(%w[RX41 2B9P])
    end

    it "follows pages until it has every course" do
      stub_courses_page(1, courses_page(%w[RX41], count: 2))
      stub_courses_page(2, courses_page(%w[2B9P], count: 2))

      courses = client.courses(year: 2027, provider_code: "C55")

      expect(courses.map { |c| c.dig("attributes", "code") }).to eq(%w[RX41 2B9P])
    end

    it "raises when the API answers with a different cycle" do
      stub_courses_page(1, courses_page(%w[RX41], count: 1, year: 2026))

      expect { client.courses(year: 2027, provider_code: "C55") }
        .to raise_error(PublishPublicAPI::Client::Error, /2026.*2027|2027.*2026/)
    end

    it "raises when courses come back without their cycle" do
      body = JSON.parse(courses_page(%w[RX41], count: 1)).merge("included" => []).to_json
      stub_courses_page(1, body)

      expect { client.courses(year: 2027, provider_code: "C55") }
        .to raise_error(PublishPublicAPI::Client::Error, "Asked for the 2027 cycle but the API didn't say which cycle it returned")
    end

    it "returns no courses when the provider has none" do
      stub_courses_page(1, { "data" => [], "included" => [], "meta" => { "count" => 0 } }.to_json)

      expect(client.courses(year: 2027, provider_code: "C55")).to eq([])
    end

    it "raises when the API errors" do
      stub_request(:get, courses_url).with(query: hash_including({})).to_return(status: 500)

      expect { client.courses(year: 2027, provider_code: "C55") }.to raise_error(Faraday::ServerError)
    end
  end

  describe "#course_locations" do
    let(:location) { { "id" => "740039", "attributes" => { "code" => "-", "urn" => "133802" } } }

    def stub_locations(has_course_schools:)
      stub_request(:get, "#{courses_url}/RX41/locations")
        .to_return(
          status: 200,
          body: { "data" => [location], "meta" => { "has_course_schools" => has_course_schools } }.to_json,
          headers: { "Content-Type" => "application/json" },
        )
    end

    it "returns the course's schools" do
      stub_locations(has_course_schools: true)

      expect(client.course_locations(year: 2027, provider_code: "C55", course_code: "RX41")).to eq([location])
    end

    # A course published without schools gets the provider's schools back instead.
    it "returns none when the course has no schools of its own" do
      stub_locations(has_course_schools: false)

      expect(client.course_locations(year: 2027, provider_code: "C55", course_code: "RX41")).to eq([])
    end
  end
end
