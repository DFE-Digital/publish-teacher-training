require "rails_helper"

describe 'GET /providers/:provider_code/courses/build_new' do
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

  describe '#build_new' do
    # todo: check returns nil for edit-options which rely on fields that aren't set yet (i.e. don't blow up)

    context 'with no parameters' do
      let(:params) { { course: {} } }

      it 'returns edit_options and errors but no model' do
        response = do_get params
        jsonapi_response = parse_response(response)

        expect(jsonapi_response['errors']).not_to be_nil # because it's not valid yet
        expect(jsonapi_response['data']).to be_nil # because it's not valid yet
        expect(jsonapi_response['meta']).not_to be_nil
        expect(jsonapi_response['meta']['edit_options']).not_to be_nil
        # todo: test "level" edit_options when it's implemented because that's the first question
        expect(jsonapi_response['meta']['edit_options']['study_modes']).to eq %w[full_time part_time full_time_or_part_time]
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

      it 'returns the course model and edit_options with no errors' do
        response = do_get params
        jsonapi_response = parse_response(response)

        course = provider.courses.new(name: 'Foo Bar Course')
        course.maths = :must_have_qualification_at_application_time
        course.english = :must_have_qualification_at_application_time
        expected_course_jsonapi = course_to_jsonapi(course)
        expect(jsonapi_response['errors']).to be_nil
        expect(jsonapi_response['data']).not_to be_nil
        expect(jsonapi_response['data']).to eq expected_course_jsonapi['data']
        expect(jsonapi_response['meta']).not_to be_nil
        expect(jsonapi_response['meta']['edit_options']).not_to be_nil
        expect(jsonapi_response['meta']['edit_options']['study_modes']).to eq %w[full_time part_time full_time_or_part_time]
      end
    end

    context 'with an invalid attribute set in query parameters' do
      let(:params) do
        { course: {
          name: 'Foo Bar Course',
          is_send: 'wibble', # invalid
          maths: 'must_have_qualification_at_application_time',
          english: 'must_have_qualification_at_application_time',
        } }
      end

      it 'returns edit_options and errors but no model' do
        response = do_get params
        expect(response).to have_http_status(:unprocessable_entity)
        jsonapi_response = parse_response(response)

        expect(jsonapi_response['errors']).to eq [{
                                            "detail" => "Is send is not included in the list",
                                            "source" => {}, # todo: make this work?
                                            "title" => "Invalid is_send"
                                          }]
        expect(jsonapi_response['meta']).not_to be_nil
        expect(jsonapi_response['meta']['edit_options']).not_to be_nil
        expect(jsonapi_response['meta']['edit_options']['study_modes']).to eq %w[full_time part_time full_time_or_part_time]
      end
    end

    context 'with an invalid enum attribute set in query parameters' do
      let(:params) do
        { course: {
          name: 'Foo Bar Course',
          maths: 'wibble', # invalid
          english: 'must_have_qualification_at_application_time',
        } }
      end

      it 'returns edit_options and errors but no model' do
        response = do_get params
        expect(response).to have_http_status(:unprocessable_entity)
        jsonapi_response = parse_response(response)

        expect(jsonapi_response['errors']).to eq [{
                                            "detail" => "Maths is invalid",
                                            "source" => {},
                                            "title" => "Invalid maths"
                                          }]
        expect(jsonapi_response['meta']['edit_options']['study_modes']).to eq %w[full_time part_time full_time_or_part_time]
      end
    end
  end

  def do_get(params)
    get "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/build_new",
        headers: { 'HTTP_AUTHORIZATION' => credentials },
        params: params
    response
  end

  def parse_response(response)
    JSON.parse(response.body)
  end

  def course_to_jsonapi(course)
    rendered_course = jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse
      }
    )
    # Converting the rendered course to JSON and back normalises any symbols
    # into strings. Better #deep_symbolize_keys because it also does values.
    JSON.parse(rendered_course.to_json)
  end
end
