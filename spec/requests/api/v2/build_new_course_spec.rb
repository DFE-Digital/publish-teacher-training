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
        SecondarySubject: API::V2::SerializableSubject,
        Provider: API::V2::SerializableProvider,
        Site: API::V2::SerializableSite,
      },
      include: [:subjects, :sites, :accrediting_provider, :provider, provider: [:sites]],
    ).to_json)
  end

  context "with subjects" do
    let(:params) do
      { course: {
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

  context "With multiple secondary subjects" do
    let(:params) do
      { course: {
        maths: "must_have_qualification_at_application_time",
        english: "must_have_qualification_at_application_time",
        subjects_ids: subjects.map(&:id),
      } }
    end
    let(:subjects) { [find_or_create(:secondary_subject, :mathematics), find_or_create(:secondary_subject, :english)] }

    it "Returns the subjects in the order they were given" do
      response = do_get params
      json_response = parse_response(response)
      response_subject_ids = json_response["data"]["relationships"]["subjects"]["data"].map { |s| s["id"].to_i }
      expect(response_subject_ids).to eq(subjects.map(&:id))
    end

    it "Generates the title in the correct order" do
      response = do_get params
      json_response = parse_response(response)
      expect(json_response["data"]["attributes"]["name"]).to eq("Mathematics with English")
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

  describe "edit options" do
    context "subjects for a secondary course" do
      let(:params) do
        { course: {
          level: :secondary,
          } }
      end

      let(:pe) { find_or_create(:secondary_subject, :physical_education) }

      context "when the current user is an admin" do
        let(:user) { create(:user, :admin, organisations: [organisation]) }

        it "should return pe as a potential subject" do
          response = do_get params
          expect(response).to have_http_status(:ok)
          json_response = parse_response(response)
          expect(json_response["data"]["meta"]["edit_options"]["subjects"].map { |subject|
            subject["attributes"]["subject_code"]
          }).to include(pe.subject_code)
        end
      end

      context "when the current user is not an admin" do
        it "should return pe as a potential subject" do
          response = do_get params
          expect(response).to have_http_status(:ok)
          json_response = parse_response(response)
          expect(json_response["data"]["meta"]["edit_options"]["subjects"].map { |subject|
            subject["attributes"]["subject_code"]
          }).not_to include(pe.subject_code)
        end
      end
    end
  end

  context "With a further education course" do
    let(:course) { Course.new(provider: provider, level: :further_education) }
    let(:params) do
      { course: { level: :further_education } }
    end

    it "Returns the course with the funding type 'fee'" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["attributes"]["funding_type"]).to eq("fee")
    end
  end

  context "with an accrediting_provider" do
    let(:course) { Course.new(provider: provider, accrediting_provider: provider2) }
    let(:params) do
      { course: { accredited_body_code: provider2.provider_code } }
    end

    it "returns the accredited_body_code" do
      response = do_get params
      expect(response).to have_http_status(:ok)
      json_response = parse_response(response)
      expect(json_response["data"]["attributes"]["accredited_body_code"]).to eq(provider2.provider_code)
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
                "title" => "Invalid sites",
                "detail" => "You must pick at least one location for this course",
                "source" => {
                  "pointer" => "/data/attributes/sites",
                },
              },
              {
                "title" => "Invalid qualification",
                "detail" => "You need to pick an outcome",
                "source" => {
                  "pointer" => "/data/attributes/qualification",
                },
              },
              {
                "title" => "Invalid applications open from",
                "detail" => "You must say when applications open from",
                "source" => {
                  "pointer" => "/data/attributes/applications_open_from",
                },
              },
              {
                "title" => "Invalid subjects",
                "detail" => "You must pick at least one subject",
                "source" => {
                  "pointer" => "/data/attributes/subjects",
                },
              },
              {
                "title" => "Invalid title",
                "detail" => "Title can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/name",
                },
              },
              {
                "title" => "Invalid profpost flag",
                "detail" => "Profpost flag can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/profpost_flag",
                },
              },
              {
                "title" => "Invalid program type",
                "detail" => "You need to pick an option",
                "source" => {
                  "pointer" => "/data/attributes/program_type",
                },
              },
              {
                "title" => "Invalid start date",
                "detail" => "Start date can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/start_date",
                },
              },
              {
                "title" => "Invalid study mode",
                "detail" => "You need to pick an option",
                "source" => {
                  "pointer" => "/data/attributes/study_mode",
                },
              },
              {
                "title" => "Invalid age range in years",
                "detail" => "You need to pick an age range",
                "source" => {
                  "pointer" => "/data/attributes/age_range_in_years",
                },
              },
              {
                "title" => "Invalid level",
                "detail" => "You need to pick a level",
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
    let(:json_response) { parse_response(response) }

    before { do_get params }

    it "Returns an 200 status" do
      expect(response).to have_http_status(:ok)
    end

    it "returns a new course with the correct attribtues" do
      expected = course_jsonapi
      expected["data"]["attributes"]["name"] = ""
      expect(json_response["data"]["attributes"]).to eq(course_jsonapi["data"]["attributes"])
    end

    it "returns a new course with the correct errors" do
      expected_errors = [
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
                "title" => "Invalid subjects",
                "detail" => "You must pick at least one subject",
                "source" => {
                  "pointer" => "/data/attributes/subjects",
                },
              },
              {
                "title" => "Invalid title",
                "detail" => "Title can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/name",
                },
              },
              {
                "title" => "Invalid profpost flag",
                "detail" => "Profpost flag can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/profpost_flag",
                },
              },
              {
                "title" => "Invalid program type",
                "detail" => "You need to pick an option",
                "source" => {
                  "pointer" => "/data/attributes/program_type",
                },
              },
              {
                "title" => "Invalid qualification",
                "detail" => "You need to pick an outcome",
                "source" => {
                  "pointer" => "/data/attributes/qualification",
                },
              },
              {
                "title" => "Invalid start date",
                "detail" => "Start date can't be blank",
                "source" => {
                  "pointer" => "/data/attributes/start_date",
                },
              },
              {
                "title" => "Invalid study mode",
                "detail" => "You need to pick an option",
                "source" => {
                  "pointer" => "/data/attributes/study_mode",
                },
              },
              {
                "title" => "Invalid age range in years",
                "detail" => "You need to pick an age range",
                "source" => {
                  "pointer" => "/data/attributes/age_range_in_years",
                },
              },
              {
                "title" => "Invalid level",
                "detail" => "You need to pick a level",
                "source" => {
                  "pointer" => "/data/attributes/level",
                },
              },
              {
                "title" => "Invalid sites",
                "detail" => "You must pick at least one location for this course",
                "source" => {
                  "pointer" => "/data/attributes/sites",
                },
              },
              {
                "title" => "Invalid applications open from",
                "detail" => "You must say when applications open from",
                "source" => {
                  "pointer" => "/data/attributes/applications_open_from",
                },
              },
        ]

      expect(json_response["data"]["errors"]).to match_array(expected_errors)
    end
  end

  context "with sufficient parameters to make a valid course" do
    let(:params) do
      { course: {
        maths: "must_have_qualification_at_application_time",
        english: "must_have_qualification_at_application_time",
        science: "must_have_qualification_at_application_time",
        study_mode: "full_time",
        start_date: DateTime.new(provider.recruitment_cycle.year.to_i, 9, 1),
        qualification: "qts",
        funding_type: "fee",
        subjects_ids: subjects.map(&:id),
        sites_ids: [sites.map(&:id)],
        level: :primary,
        age_range_in_years: "3_to_7",
        applications_open_from: provider.recruitment_cycle.application_start_date,
        } }
    end

    let(:sites) { [create(:site, provider: provider)] }
    let(:subjects) { [find_or_create(:primary_subject, :primary_with_mathematics)] }
    let(:course) do
      Course.new({ provider: provider, subjects: subjects, sites: sites }.merge(params[:course].slice!(:subjects_ids, :sites_ids)))
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
