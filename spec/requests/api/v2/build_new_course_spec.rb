require "rails_helper"

describe "/api/v2/build_new_course", type: :request do
  let(:user) { create(:user, organisations: [organisation]) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation)      { create :organisation }
  let(:provider) do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           provider_type: "Y"
  end
  let(:provider2) { create(:provider) }

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
        Provider: API::V2::SerializableProvider,
        Site: API::V2::SerializableSite,
      },
      include: [:subjects, :sites, :accrediting_provider, :provider, provider: [:sites]],
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
    let(:subjects) { [find_or_create(:primary_subject, :primary_with_mathematics)] }

    it "returns a course with subject relationships" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["relationships"]["subjects"]).to eq(course_jsonapi["data"]["relationships"]["subjects"])
    end

    it "returns the generated title" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expect(json_response["data"]["attributes"]["name"]).to eq("Primary with mathematics")
    end
  end

  context "providers" do
    let(:site) { build(:site) }
    let(:provider) do
      create :provider,
             organisations: [organisation],
             recruitment_cycle: recruitment_cycle,
             provider_type: "Y",
             sites: [site]
    end
    let(:course) { Course.new(provider: provider) }
    let(:params) do
      { provider_code: provider.provider_code, course: {} }
    end

    it "return a providers" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["relationships"]["provider"]["data"]["id"].to_i).to eq(provider.id)
    end

    it "returns the provider sites" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["included"].first["relationships"]["sites"]["data"].first["id"].to_i).to eq(site.id)
    end
  end

  context "with an accrediting_provider" do
    let(:course) { Course.new(provider: provider, accrediting_provider: provider2) }
    let(:params) do
      { course: { accrediting_provider_code: provider2.provider_code } }
    end

    it "returns the accrediting_provider_code" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["attributes"]["accrediting_provider_code"]).to eq(provider2.provider_code)
    end

    it "returns the accrediting provider includes" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = ""
      expected["data"]["errors"] = [
              {
                "title" => "Invalid maths",
                "detail" => "Pick an option for Maths",
                "source" => {
                  "pointer" => "/data/attributes/maths",
                },
              },
              {
                "title" => "Invalid english",
                "detail" => "Pick an option for English",
                "source" => {
                  "pointer" => "/data/attributes/english",
                },
              },
              {
                "title" => "Invalid name",
                "detail" => "Name can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/name",
                },
              },
              {
                "title" => "Invalid profpost_flag",
                "detail" => "Profpost flag can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/profpost_flag",
                },
              },
              {
                "title" => "Invalid program_type",
                "detail" => "Program type can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/program_type",
                },
              },
              {
                "title" => "Invalid qualification",
                "detail" => "Qualification can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/qualification",
                },
              },
              {
                "title" => "Invalid start_date",
                "detail" => "Start date can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/start_date",
                },
              },
              {
                "title" => "Invalid study_mode",
                "detail" => "Study mode can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/study_mode",
                },
              },
              {
                "title" => "Invalid age_range_in_years",
                "detail" => "Age range in years can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/age_range_in_years",
                },
              },
              {
                "title" => "Invalid level",
                "detail" => "Level can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/level",
                },
              },
        ]
      expect(json_response).to eq expected
    end
  end


  context "with no parameters" do
    let(:params) do
      { course: {} }
    end

    it "returns a new course with errors" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = ""
      expected["data"]["errors"] = [
              {
                "title" => "Invalid maths",
                "detail" => "Pick an option for Maths",
                "source" => {
                  "pointer" => "/data/attributes/maths",
                },
              },
              {
                "title" => "Invalid english",
                "detail" => "Pick an option for English",
                "source" => {
                  "pointer" => "/data/attributes/english",
                },
              },
              {
                "title" => "Invalid name",
                "detail" => "Name can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/name",
                },
              },
              {
                "title" => "Invalid profpost_flag",
                "detail" => "Profpost flag can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/profpost_flag",
                },
              },
              {
                "title" => "Invalid program_type",
                "detail" => "Program type can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/program_type",
                },
              },
              {
                "title" => "Invalid qualification",
                "detail" => "Qualification can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/qualification",
                },
              },
              {
                "title" => "Invalid start_date",
                "detail" => "Start date can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/start_date",
                },
              },
              {
                "title" => "Invalid study_mode",
                "detail" => "Study mode can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/study_mode",
                },
              },
              {
                "title" => "Invalid age_range_in_years",
                "detail" => "Age range in years can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/age_range_in_years",
                },
              },
              {
                "title" => "Invalid level",
                "detail" => "Level can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/level",
                },
              },
        ]

      expect(json_response).to eq expected
    end
  end

  context "with sufficient parameters to make a valid course" do
    let(:params) do
      { course: {
        maths: "must_have_qualification_at_application_time",
        english: "must_have_qualification_at_application_time",
        science: "must_have_qualification_at_application_time",
        name: "Primary",
        study_mode: "full_time",
        start_date: DateTime.new(provider.recruitment_cycle.year.to_i, 9, 1),
        qualification: "qts",
        funding_type: "fee",
        subjects_ids: subjects.map(&:id),
        level: :primary,
        age_range_in_years: "3_to_7",
        } }
    end

    let(:subjects) { [find_or_create(:primary_subject, :primary_with_mathematics)] }
    let(:course) do
      Course.new({ provider: provider, subjects: subjects }.merge(params[:course].slice!(:subjects_ids)))
    end

    it "returns a matching course with no errors" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)

      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = "Primary with mathematics"
      expected["data"]["errors"] = []


      expect(json_response).to eq expected
    end
  end

  context "With sites_ids" do
    let(:site_one) { create(:site, provider: provider) }
    let(:site_two) { create(:site, provider: provider) }
    let(:site_ids) { [site_one.id, site_two.id] }

    let(:params) do
      {
        course: {
          study_mode: "full_time",
          sites_ids: site_ids,
        },
      }
    end

    it "returns a matching course with site information" do
      response = do_get params
      json_response = parse_response(response)

      course_site_ids = json_response["data"]["relationships"]["sites"]["data"].map { |s| s["id"].to_i }
      expect(course_site_ids).to match_array(site_ids)
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
