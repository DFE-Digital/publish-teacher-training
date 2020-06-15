require "net/http"
require "rspec-benchmark"
require "webmock"

TEST_SAMPLE_COUNT = 5

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def get(path)
  uri = URI(ENV.fetch("CUSTOM_HOST_NAME", "http://localhost:3001"))
  uri.path = path
  Net::HTTP.get(uri)
end

recruitment_cycle = ENV.fetch("RECRUITMENT_CYCLE", "2020")
provider_code = ENV.fetch("PROVIDER_CODE", "U80")
course_code = ENV.fetch("COURSE_CODE", "2P3K")

tests = {
  "/api/v3/recruitment_cycles/#{recruitment_cycle}/providers/#{provider_code}" => 375,
  "/api/v3/recruitment_cycles/2020/providers/#{provider_code}/courses/#{course_code}" => 300,
  "/api/v3/courses" => 4750,
}

describe "API performance", type: :performance do
  before do
    WebMock.allow_net_connect!
  end

  tests.each do |url, time_in_ms|
    it "#{url} responds under #{time_in_ms}ms" do
      expect {
        get url
      }.to perform_under(time_in_ms).ms.sample(TEST_SAMPLE_COUNT).times
    end
  end
end
