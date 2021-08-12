require "rails_helper"

module BigQuery
  describe RequestEvent do
    let(:event) { described_class.new }

    describe "#as_json" do
      subject { event.as_json }

      context "initialized" do
        it {  is_expected.to include("environment" => "test") }
        it {  is_expected.to include("event_type" => "web_request") }

        it "contains Time.now in iso8601" do
          Time.freeze do
            expected_time = Time.zone.now.iso8601
            expect(subject).to include("occurred_at" => expected_time)
          end
        end
      end

      context "with_request_details set" do
        let(:request) do
          double(
            uuid: "uuid",
            path: "/path",
            method: "GET",
            user_agent: "browser-stuff",
            query_string: "test=one&other-test=two",
            referer: "https://www.example.com",
            remote_ip: "120.0.0.1",
          )
        end
        let(:sha2_hashed_browser_stuff_plus_ip) { "03c72584280cb752f8bf5e662a55ef1adafb3f628812bb9f08fe32dd1e0f6352" }

        before do
          event.with_request_details(request)
        end

        it {  is_expected.to include("request_uuid" => "uuid") }
        it {  is_expected.to include("request_path" => "/path") }
        it {  is_expected.to include("request_method" => "GET") }
        it {  is_expected.to include("request_user_agent" => "browser-stuff") }
        it {  is_expected.to include("anonymised_user_agent_and_ip" => sha2_hashed_browser_stuff_plus_ip) }

        it {
          expect(subject).to include("request_query" => [
            { "key" => "test", "value" => ["one"] },
            { "key" => "other-test", "value" => ["two"] },
          ])
        }

        it { is_expected.to include("request_referer" => "https://www.example.com") }
      end

      context "with_response_details set" do
        let(:response) do
          double(
            content_type: "words",
            status: 200,
          )
        end

        before do
          event.with_response_details(response)
        end

        it {  is_expected.to include("response_content_type" => "words") }
        it {  is_expected.to include("response_status" => 200) }
      end

      context "with_user set" do
        before do
          event.with_user(user)
        end

        context "user is present" do
          let(:user) do
            double(
              id: 1,
            )
          end

          it { is_expected.to include("user_id" => 1) }
        end

        context "user is nil" do
          let(:user) { nil }

          it { is_expected.to include("user_id" => nil) }
        end
      end
    end
  end
end
