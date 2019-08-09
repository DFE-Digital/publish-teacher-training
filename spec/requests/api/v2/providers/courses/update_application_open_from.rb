require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_applications_open_from)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = updated_applications_open_from

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { build :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }

  let(:course)            {
    create :course,
           provider: provider,
           applications_open_from: applications_open_from
  }

  let(:applications_open_from) { DateTime.new(provider.recruitment_cycle.year.to_i, 1, 15).utc }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[updated_applications_open_from]
  end

  before do
    perform_request(updated_applications_open_from)
  end

  context "course has an updated applications_open_from" do
    let(:updated_applications_open_from) { { applications_open_from: DateTime.new(provider.recruitment_cycle.year.to_i, 1, 1).utc } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates applications_open_from attribute to the correct value" do
      expect(course.reload.applications_open_from.to_date).to eq(updated_applications_open_from[:applications_open_from])
    end
  end

  context "course has the same applications_open_from" do
    context "with values passed into the params" do
      let(:updated_applications_open_from) { { applications_open_from: applications_open_from } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change qualification attribute" do
        expect(course.reload.applications_open_from).to eq(updated_applications_open_from[:applications_open_from])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_applications_open_from) { {} }
    let!(:course_applications_open_from) { course.applications_open_from }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change applications_open_from attribute" do
      expect(course.reload.applications_open_from).to eq(course_applications_open_from)
    end
  end


  context 'for a course in the current cycle' do
    context 'with an invalid applications_open_from' do
      let(:updated_applications_open_from) { { applications_open_from: DateTime.new(provider.recruitment_cycle.year.to_i - 2, 1, 1).utc } }
      let(:json_data) { JSON.parse(response.body)['errors'] }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("#{updated_applications_open_from[:applications_open_from]} is not valid for the #{provider.recruitment_cycle.year} cycle")
      end
    end
  end

  context 'for a course in the next cycle' do
    context 'with an invalid applications_open_from' do
      let(:updated_applications_open_from) { { applications_open_from: DateTime.new(provider.recruitment_cycle.year.to_i - 1, 9, 31) } }
      let(:json_data) { JSON.parse(response.body)['errors'] }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_data.count).to eq 1
        expect(response.body).to include("#{updated_applications_open_from[:applications_open_from]} is not valid for the #{provider.recruitment_cycle.year} cycle")
      end
    end
  end
end
