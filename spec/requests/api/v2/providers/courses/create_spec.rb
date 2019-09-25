require "rails_helper"

describe "Course POST #create API V2", type: :request do
  let(:user)         { create(:user) }
  let(:organisation) { create(:organisation, users: [user]) }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt(:apiv2, payload: payload) }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:provider) { create(:provider, organisations: [organisation]) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:course) { build(:course, provider: provider) }
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:create_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{course.provider.provider_code}/courses"
  end

  def perform_request(course)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    post  create_path,
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end

  subject do
    perform_request(course)
    response
  end

  context "when unauthenticated" do
    let(:payload) { { email: "foo@bar" } }

    it { should have_http_status(:unauthorized) }
  end

  context "when unauthorised" do
    let(:unauthorised_user) { create(:user) }
    let(:payload) { { email: unauthorised_user.email } }

    it "raises an error" do
      expect { perform_request(course) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  context "when authorised" do
    let(:created_course) { provider.courses.last }

    it "returns http success" do
      expect(subject).to have_http_status(:success)
    end

    it "creates a course with the correct attributes" do
      expect { perform_request(course) }.to change { provider.reload.courses.count }.from(0).to(1)
      expect(created_course.english).to eq(course.english)
      expect(created_course.maths).to eq(course.maths)
      expect(created_course.science).to eq(course.science)
      expect(created_course.qualification).to eq(course.qualification)
      expect(created_course.age_range_in_years).to eq(course.age_range_in_years)
      expect(created_course.start_date).to eq(course.start_date)
      expect(created_course.applications_open_from).to eq(course.applications_open_from)
      expect(created_course.study_mode).to eq(course.study_mode)
      expect(created_course.is_send).to eq(course.is_send)
      expect(created_course.name).to eq(course.name)
      expect(created_course.course_code).to match(/^[A-Z]\d{3}$/)
    end

    context "when a provider already has a course" do
      let!(:existing_course) { create(:course, provider: provider) }

      it "creates a course with a different code" do
        expect { perform_request(course) }.to change { provider.reload.courses.count }.from(1).to(2)
        expect(created_course.course_code).to match(/^[A-Z]\d{3}$/)
        expect(created_course.course_code).to_not eq(existing_course.course_code)
      end
    end
  end
end
