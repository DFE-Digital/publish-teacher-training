require "rails_helper"

describe ManageCoursesAPI do
  describe "Connection.api" do
    subject { ManageCoursesAPI::Connection.api }

    it "exposes an Faraday connection" do
      should be_instance_of(Faraday::Connection)
    end

    it "uses the configured URL as the base" do
      expect(subject.url_prefix.to_s).to eq(Settings.manage_api.base_url + "/")
    end

    it "uses the configured secret for the bearer token" do
      expect(subject.headers["Authorization"]).to eq("Bearer #{Settings.manage_api.secret}")
    end
  end

  describe "Request" do
    subject { ManageCoursesAPI::Request }

    describe 'sync_course_with_search_and_compare' do
      let(:provider_code) { 'X12' }
      let(:course_code) { 'X123' }
      let(:email) { 'foo@bar' }
      let(:body) { { "email": email } }

      describe "with a normal response" do
        before do
          stub_request(:post, Settings.manage_api.base_url + "/api/Publish/internal/course/#{provider_code}/#{course_code}")
            .with { |req| req.body == body }
            .to_return(
              status: 200,
              body: '{ "result": true }'
            )
        end

        it "returns true" do
          result = subject.sync_course_with_search_and_compare(
            email, provider_code, course_code
          )
          expect(result).to eq(true)
        end
      end
    end
  end
end
