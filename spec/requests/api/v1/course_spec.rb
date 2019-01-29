require "rails_helper"

RSpec.describe "Courses API", type: :request do
  describe 'GET index' do
    before do
      provider = FactoryBot.create(:provider,
                                   provider_name: "ACME SCITT",
                                   provider_code: "2LD",
                                   provider_type: "SCITT",
                                   site_count: 0,
                                   course_count: 0,
                                   address1: "Sydney Russell School",
                                   address2: "Parsloes Avenue",
                                   address3: "Dagenham",
                                   address4: "Essex",
                                   postcode: "RM9 5QT",
                                   region_code: 'Eastern',
                                   scheme_member: 'Y',
                                   enrichments: [])

      site = FactoryBot.create(:site, code: "-", location_name: "Main Site", provider: provider)
      subject1 = FactoryBot.create(:subject, subject_code: "1", subject_name: "Secondary")
      subject2 = FactoryBot.create(:subject, subject_code: "2", subject_name: "Mathematics")

      course = FactoryBot.create(:course,
        course_code: "2HPF",
        start_date: Date.new(2019, 9, 1),
        name: "Religious Education",
        qualification: 1,
        sites: [site],
        subjects: [subject1, subject2],
        study_mode: "full time",
        age_range: 'primary',
        english: 3,
        maths: 9,
        profpost_flag: "Postgraduate",
        program_type: "School Direct training programme",
        modular: "",
        provider: provider)

      course.site_statuses.first.update(
        vac_status: 'Full time vacancies',
        publish: 'Y',
        status: 'Running',
        applications_accepted_from: "2018-10-09 00:00:00"
      )
    end

    it "returns http success" do
      get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("bats") }
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorised" do
      get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("foo") }
      expect(response).to have_http_status(:unauthorized)
    end

    it "JSON body response contains expected course attributes" do
      get "/api/v1/2019/courses", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("bats") }

      json = JSON.parse(response.body)
      expect(json). to eq([
        {
          "course_code" => "2HPF",
          "start_month" => "2019-09-01T00:00:00Z",
          "start_month_string" => "September",
          "name" => "Religious Education",
          "study_mode" => "F",
          "copy_form_required" => "Y",
          "profpost_flag" => "PG",
          "program_type" => "SD",
          "age_range" => "P",
          "modular" => "",
          "english" => 3,
          "maths" => 9,
          "science" => nil,
          "qualification" => 1,
          "recruitment_cycle" => "2019",
          "campus_statuses" => [
            {
              "campus_code" => "-",
              "name" => "Main Site",
              "vac_status" => "F",
              "publish" => "Y",
              "status" => "R",
              "course_open_date" => "2018-10-09",
              "recruitment_cycle" => "2019"
            }
          ],
          "subjects" => [
            {
              "subject_code" => "1",
              "subject_name" => "Secondary"
            },
            {
              "subject_code" => "2",
              "subject_name" => "Mathematics"
            }
          ],
          "provider" => {
            "institution_code" => "2LD",
            "institution_name" => "ACME SCITT",
            "institution_type" => "B",
            "accrediting_provider" => 'N',
            "address1" => "Sydney Russell School",
            "address2" => "Parsloes Avenue",
            "address3" => "Dagenham",
            "address4" => "Essex",
            "postcode" => "RM9 5QT",
            "region_code" => "07",
            "scheme_member" => "Y"
          },
          "accrediting_provider" => nil
        }
      ])
    end
  end
end
