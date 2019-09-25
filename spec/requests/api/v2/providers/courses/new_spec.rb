require "rails_helper"

describe "GET /providers/:provider_code/courses/new" do
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation)      { create :organisation }
  let(:provider) do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle
  end
  let(:user)    { create :user, organisations: [organisation] }
  let(:payload) { { email: user.email } }
  let(:token)   { build_jwt :apiv2, payload: payload }
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }

  describe "#new" do
    it "returns a new course resource" do
      get "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/new",
          headers: { "HTTP_AUTHORIZATION" => credentials }

      course = provider.courses.new # Course.new(provider: provider)
      rendered_course = jsonapi_renderer.render(
        course,
        class: {
          Course: API::V2::SerializableCourse,
        },
      )
      # Converting the rendered course to JSON and back normalises any symbols
      # into strings. Better #deep_symbolize_keys because it also does values.
      jsonapi_course = JSON.parse(rendered_course.to_json)
      jsonapi_response = JSON.parse(response.body)
      expect(jsonapi_response["data"]).to eq jsonapi_course["data"]
    end
  end
end
