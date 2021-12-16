require "rails_helper"

describe "Courses API v2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:credentials) { encode_to_credentials(payload) }
  let(:current_cycle) { find_or_create :recruitment_cycle }
  let(:subjects) { [course_subject_mathematics] }

  let(:provider1)       { create :provider, organisations: [organisation] }
  let(:provider2)       { create :provider, organisations: [organisation] }
  let(:accredited_body) { create :provider, :accredited_body }

  let(:course1) { create(:course, provider: provider1) }
  let(:course2) { create(:course, provider: provider2) }
  let(:course3) { create(:course) }
  let(:course4) { create(:course, provider: provider1, accrediting_provider: accredited_body) }

  let(:provider3) { create :provider, :previous_recruitment_cycle, organisations: [organisation] }
  let(:previous_cycle_course) { create(:course, provider: provider3) }

  describe "GET index" do
    subject { perform_request(request_path) }

    def perform_request(path)
      course1
      course2
      course3
      course4
      previous_cycle_course
      get path,
          headers: { "HTTP_AUTHORIZATION" => credentials }
      response
    end

    context "request without filters" do
      let(:request_path) do
        "#{api_v2_recruitment_cycle_courses_path(current_cycle.year)}?include=subjects"
      end

      it "returns user related courses" do
        json_response = JSON.parse subject.body

        expect(response).to have_http_status(:success)
        expect(json_response["data"].count).to eq(3)
        expect(json_response["data"].pluck("id")).not_to include(course3.id.to_s, previous_cycle_course.id.to_s)
        expect(json_response["included"].first["type"]).to eq("subjects")
      end

      context "when a course is discarded" do
        before do
          course1.discard!
        end

        it "doesn't return it" do
          json_response = JSON.parse subject.body

          expect(json_response["data"].pluck("id")).to match_array([course2.id.to_s, course4.id.to_s])
        end
      end
    end

    context "request with accredited_body_code filter" do
      let(:request_path) do
        api_v2_recruitment_cycle_courses_path(current_cycle.year) +
          "?include=subjects&filter[accredited_body_code]=#{accredited_body.provider_code}"
      end

      it "returns user related courses filtered by accredited body" do
        json_response = JSON.parse subject.body
        expect(json_response["data"].pluck("id")).to eq([course4.id.to_s])
        expect(json_response["included"].first["type"]).to eq("subjects")
      end

      context "for multiple codes" do
        let(:request_path) do
          api_v2_recruitment_cycle_courses_path(current_cycle.year) +
            "?filter[accredited_body_code][]=#{accredited_body.provider_code}" \
            "&filter[accredited_body_code][]=#{accredited_body2.provider_code}"
        end

        let(:accredited_body2) { create :provider, :accredited_body }
        let!(:course5) { create(:course, provider: provider1, accrediting_provider: accredited_body2) }

        it "returns user related courses filtered by accredited body" do
          json_response = JSON.parse subject.body
          expect(json_response["data"].pluck("id")).to match_array([course4.id.to_s, course5.id.to_s])
        end
      end
    end
  end
end
