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
    let(:provider_code) { 'X12' }
    let(:email) { 'foo@bar' }
    let(:body) { { "email": email } }

    before do
      stub_request(:post, "#{Settings.manage_api.base_url}/#{endpoint}")
        .with { |req| req.body == body.to_json }
        .to_return(
          status: 200,
          body: '{ "result": true }'
        )
    end

    describe 'sync_course_with_search_and_compare' do
      let(:course_code) { 'X123' }

      describe "with a normal response" do
        let(:endpoint) { "api/Publish/internal/course/#{provider_code}/#{course_code}" }

        it "returns true" do
          result = subject.sync_course_with_search_and_compare(
            email, provider_code, course_code
          )
          expect(result).to eq(true)
        end
      end

      describe 'sync_courses_with_search_and_compare' do
        let(:endpoint) { "api/Publish/internal/course/#{provider_code}" }

        describe "with a normal response" do
          it "returns true" do
            result = subject.sync_courses_with_search_and_compare(
              email, provider_code
            )
            expect(result).to eq(true)
          end
        end
      end
    end
  end
end
