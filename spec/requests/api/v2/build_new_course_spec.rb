require "rails_helper"

describe "/api/v2/build_new_course", type: :request do
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
  let(:subjects) { [] }
  let(:course) { Course.new(provider: provider, subjects: subjects) }
  let(:course_jsonapi) do
    JSON.parse(jsonapi_renderer.render(
      course,
      class: {
        Course: API::V2::SerializableCourse,
        Subject: API::V2::SerializableSubject,
        PrimarySubject: API::V2::SerializableSubject,
      },
      include: [:subjects],
    ).to_json)
  end

  context "with subjects" do
    let(:params) do
      { course: {
        name: "Foo Bar Course",
        maths: "must_have_qualification_at_application_time",
        english: "must_have_qualification_at_application_time",
        subjects_ids: subjects.map(&:id),
      } }
    end
    let(:subjects) { [find_or_create(:subject, :primary_with_mathematics)] }

    it "returns a course with subject relationships" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["relationships"]).to eq(course_jsonapi["data"]["relationships"])
    end

    it "returns the generated title" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expect(json_response["data"]["attributes"]["name"]).to eq("Primary with mathematics")
    end
  end

  context "with no parameters" do
    let(:params) { { course: {} } }

    it "returns a new course with errors" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = ""
      expected["data"]["errors"] = [
        { "title" => "Invalid maths",
          "detail" => "Pick an option for Maths",
          "source" => { "pointer" => "/data/attributes/maths" } },
        { "title" => "Invalid english",
          "detail" => "Pick an option for English",
          "source" => { "pointer" => "/data/attributes/english" } },
      ]

      expect(json_response).to eq expected
    end
  end

  context "with sufficient parameters to make a valid course" do
    let(:params) do
      { course: {
        maths: "must_have_qualification_at_application_time",
        english: "must_have_qualification_at_application_time",
      } }
    end

    let(:course) { Course.new({ provider: provider }.merge(params[:course])) }

    it "returns a matching course with no errors" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = ""
      expected["data"]["errors"] = []


      expect(json_response).to eq expected
    end
  end

  def do_get(params)
    get "/api/v2/build_new_course?year=#{recruitment_cycle.year}" \
          "&provider_code=#{provider.provider_code}",
        headers: { "HTTP_AUTHORIZATION" => credentials },
        params: params
    response
  end

  def parse_response(response)
    JSON.parse(response.body)
  end
end
