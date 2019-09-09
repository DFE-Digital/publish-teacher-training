require "rails_helper"

describe '/api/v2/build_new_course', type: :request do
  let(:user) { create(:user, organisations: [organisation]) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation)      { create :organisation }
  let(:provider) do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle
  end
  let(:payload) { { email: user.email } }
  let(:token) do
    JWT.encode payload,
               Settings.authentication.secret,
               Settings.authentication.algorithm
  end
  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:course) { Course.new(provider: provider) }
  let(:course_jsonapi) do
    JSON.parse(jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    ).to_json)['data']
  end

  context 'with no parameters' do
    let(:params) { { course: {} } }

    it 'returns a blank course, a bunch of errors and loads of edit_options' do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expected = {
        "data" => course_jsonapi.merge(
          "errors" => [
            { "title" => "Invalid maths",
              "detail" => "Pick an option for Maths",
              "source" => { "pointer" => "/data/attributes/maths" } },
            { "title" => "Invalid english",
              "detail" => "Pick an option for English",
              "source" => { "pointer" => "/data/attributes/english" } }
          ]
        )
      }

      expect(json_response).to eq expected
    end
  end

  context 'with enough attributes set in query parameters to make a valid course' do
    let(:params) do
      { course: {
        name: 'Foo Bar Course',
        maths: 'must_have_qualification_at_application_time',
        english: 'must_have_qualification_at_application_time',
        # todo: why is this valid when level not set? A: because level has a default. What to do about that if anything?
      } }
    end

    let(:course) { Course.new({ provider: provider }.merge(params[:course])) }

    it 'returns the course model and edit_options with no errors' do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expected = { "data" => course_jsonapi.merge("errors" => []) }

      expect(json_response).to eq expected
    end
  end

  def do_get(params)
    get "/api/v2/build_new_course?year=#{recruitment_cycle.year}" \
          "&provider_code=#{provider.provider_code}",
        headers: { 'HTTP_AUTHORIZATION' => credentials },
        params: params
    response
  end

  def parse_response(response)
    JSON.parse(response.body)
  end
end
