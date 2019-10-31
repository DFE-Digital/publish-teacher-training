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
  let(:site_one) { create(:site, provider: provider) }
  let(:site_two) { create(:site, provider: provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }
  let(:primary_with_mathematics) { find_or_create(:primary_subject, :primary_with_mathematics) }
  let(:course) do
    build(
      :course,
      provider: provider,
      subjects: [primary_with_mathematics],
      sites: [site_one, site_two],
    )
  end
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
        PrimarySubject: API::V2::SerializableSubject,
        Site: API::V2::SerializableSite,
      },
      include: %i[subjects sites],
    )

    # jsonapi can't send included objects but the renderer will render it with
    # included objects so we have to remove them
    post create_path,
         headers: { "HTTP_AUTHORIZATION" => credentials },
         params: {
           _jsonapi: { data: jsonapi_data[:data] },
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
      expect(created_course.level).to eq(course.level)
      expect(created_course.english).to eq(course.english)
      expect(created_course.maths).to eq(course.maths)
      expect(created_course.science).to eq(course.science)
      expect(created_course.qualification).to eq(course.qualification)
      expect(created_course.age_range_in_years).to eq(course.age_range_in_years)
      expect(created_course.start_date).to eq(course.start_date)
      expect(created_course.applications_open_from).to eq(course.applications_open_from)
      expect(created_course.study_mode).to eq(course.study_mode)
      expect(created_course.is_send).to eq(course.is_send)
      expect(created_course.name).to eq("Primary with mathematics")
      expect(created_course.course_code).to match(/^[A-Z]\d{3}$/)
      expect(created_course.subjects).to match_array([primary_with_mathematics])
      expect(created_course.sites).to match_array([site_one, site_two])
    end

    context "when a provider already has a course" do
      let!(:existing_course) { create(:course, provider: provider) }

      it "creates a course with a different code" do
        expect { perform_request(course) }.to change { provider.reload.courses.count }.from(1).to(2)
        expect(created_course.course_code).to match(/^[A-Z]\d{3}$/)
        expect(created_course.course_code).to_not eq(existing_course.course_code)
      end
    end

    context "When a provider is not accredited" do
      let(:provider) { create(:provider, :accredited_body, organisations: [organisation]) }
      let(:course) do
        build(
          :course,
          provider: provider,
          subjects: [primary_with_mathematics],
          sites: [site_one, site_two],
          funding_type: "fee",
        )
      end

      it "Creates a course" do
        expect { perform_request(course) }.to change { provider.reload.courses.count }.from(0).to(1)
      end
    end
  end
end
