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
    it 'returns a new course resource' do
      params = nil
      response = do_get params

      course = provider.courses.new
      expected_course_jsonapi = course_to_jsonapi(course)
      expect(response['errors']).to be_nil
      expect(response['data']).to_not be_nil
      expect(response['data']).to eq expected_course_jsonapi['data']
    end

    context 'with course attributes set in query parameters' do
      it 'intialises the course with the provider attributes' do
        params = { course: {
          name: 'Foo Bar Course',
          maths: 'must_have_qualification_at_application_time',
          english: 'must_have_qualification_at_application_time',
        } }
        response = do_get params

        course = provider.courses.new(name: 'Foo Bar Course')
        course.maths = :must_have_qualification_at_application_time
        course.english = :must_have_qualification_at_application_time
        expected_course_jsonapi = course_to_jsonapi(course)
        expect(response['errors']).to be_nil
        expect(response['data']).to_not be_nil
        expect(response['data']).to eq expected_course_jsonapi['data']
      end

      context 'with an invalid value' do
        it 'returns a useful error' do
          params = { course: {
            name: 'Monkey matters',
            is_send: 'wibble', # invalid
            maths: 'must_have_qualification_at_application_time',
            english: 'must_have_qualification_at_application_time',
          } }
          response = do_get params

          expect(response['errors']).to eq [{
                                              "detail" => "Is send is not included in the list",
                                              "source" => {},
                                              "title" => "Invalid is_send"
                                            }]
          expect(response['data']).to be_nil
        end
      end

      context 'with an invalid enum value' do
        it 'returns a useful error' do
          params = { course: {
            name: 'Foo Bar Course',
            maths: 'wibble',
            english: 'must_have_qualification_at_application_time',
          } }
          response = do_get params

          expect(response['errors']).to eq [{
                                              "detail" => "Maths is invalid",
                                              "source" => {},
                                              "title" => "Invalid maths"
                                            }]
          expect(response['data']).to be_nil
        end
      end
    end
  end

  # trying out avoiding let syntax by doing DRY with normal functions

  def do_get(params)
    get "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/build_new",
        headers: { 'HTTP_AUTHORIZATION' => credentials },
        params: params

    jsonapi_response = JSON.parse(response.body)
    jsonapi_response
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
