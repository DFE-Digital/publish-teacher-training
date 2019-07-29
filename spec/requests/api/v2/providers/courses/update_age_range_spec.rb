require "rails_helper"

describe 'PATCH /providers/:provider_code/courses/:course_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  def perform_request(updated_age_range_in_years)
    jsonapi_data = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )

    jsonapi_data[:data][:attributes] = updated_age_range_in_years

    patch "/api/v2/providers/#{course.provider.provider_code}" \
            "/courses/#{course.course_code}",
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end
  let(:organisation)      { create :organisation }
  let(:provider)          { create :provider, organisations: [organisation] }
  let(:user)              { create :user, organisations: [organisation] }
  let(:payload)           { { email: user.email } }
  let(:token)             { build_jwt :apiv2, payload: payload }

  let(:course)            {
    create :course,
           provider: provider,
           age_range_in_years: age_range_in_years
  }
  let(:age_range_in_years) { '3_to_7' }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:permitted_params) do
    %i[updated_age_range_in_years]
  end

  before do
    perform_request(updated_age_range_in_years)
  end

  context "course has an updated age range in years" do
    let(:updated_age_range_in_years) { { age_range_in_years: '3_to_7' } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates the age_range_in_years attribute to the correct value" do
      expect(course.reload.age_range_in_years).to eq(updated_age_range_in_years[:age_range_in_years])
    end
  end

  context "course has the same age_range_in_years" do
    context "with values passed into the params" do
      let(:updated_age_range_in_years) { { age_range_in_years: '3_to_7' } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "does not change age_range_in_years attribute" do
        expect(course.reload.age_range_in_years).to eq(updated_age_range_in_years[:age_range_in_years])
      end
    end
  end

  context "with no values passed into the params" do
    let(:updated_age_range_in_years) { {} }

    before do
      @age_range_in_years = course.age_range_in_years
      perform_request(updated_age_range_in_years)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "does not change age_range_in_years attribute" do
      expect(course.reload.age_range_in_years).to eq(@age_range_in_years)
    end
  end
end
