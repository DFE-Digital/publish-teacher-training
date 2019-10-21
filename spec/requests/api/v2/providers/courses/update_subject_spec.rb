require "rails_helper"

describe "PATCH /providers/:provider_code/courses/:course_code" do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_subjects)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
      },
    )

    jsonapi_data[:data][:relationships] = updated_subjects

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { "HTTP_AUTHORIZATION" => credentials },
          params: {
            _jsonapi: jsonapi_data,
          }
  end
  let(:organisation) { create :organisation }
  let(:provider) { create :provider, organisations: [organisation], sites: [site] }
  let(:user) { create :user, organisations: [organisation] }
  let(:payload) { { email: user.email } }
  let(:token) { build_jwt :apiv2, payload: payload }

  let(:site) { build(:site) }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  before do
    perform_request(updated_subjects)
  end

  context "course has no subjects" do
    let(:course) { create(:course, :infer_level, provider: provider) }
    let(:subject) { find_or_create(:secondary_subject, :mathematics) }
    let(:updated_subjects) do
      {
        subjects: {
          data: [{ "type" => "subject", "id" => subject.id.to_s }],
        },
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "adds a subject" do
      expect(course.reload.subjects.first.id).to eq(subject.id)
    end
  end

  context "course has subjects" do
    let(:course) { create(:course, :infer_level, provider: provider, subjects: []) }
    let(:subject1) { find_or_create(:secondary_subject, :english) }
    let(:subject2) { find_or_create(:secondary_subject, :mathematics) }
    let(:updated_subjects) do
      {
        subjects: {
          data: [
            { type: "subject", id: subject1.id.to_s },
            { type: "subject", id: subject2.id.to_s },
          ],
        },
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "adds a subject" do
      expect(course.reload.subjects.first.id).to eq(subject1.id)
      expect(course.reload.subjects.second.id).to eq(subject2.id)
    end
  end
end
