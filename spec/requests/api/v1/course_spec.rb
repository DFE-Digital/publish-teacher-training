require "rails_helper"

RSpec.describe "Courses API", type: :request do
  describe 'GET index' do
    before do
      provider = FactoryBot.create(:provider, provider_name: "ACME SCITT", provider_code: "2LD", site_count: 0, course_count: 0)
      site = FactoryBot.create(:site, code: "-", location_name: "Main Site", provider: provider)
      subject1 = FactoryBot.create(:subject, subject_code: "1", subject_name: "Secondary")
      subject2 = FactoryBot.create(:subject, subject_code: "2", subject_name: "Mathematics")

      FactoryBot.create(:course,
        course_code: "2HPF",
        name: "Religious Education",
        qualification: 1,
        sites: [site],
        subjects: [subject1, subject2],
        provider: provider)

      get "/api/v1/courses", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bat", "beta") }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "JSON body response contains expected course attributes" do
      json = JSON.parse(response.body)
      expect(json). to eq([
        {
          "course_code" => "2HPF",
          "start_month" => nil,
          "name" => "Religious Education",
          "study_mode" => nil,
          "copy_form_required" => "Y",
          "profpost_flag" => nil,
          "program_type" => nil,
          "modular" => nil,
          "english" => nil,
          "maths" => nil,
          "science" => nil,
          "qualification" => 1,
          "recruitment_cycle" => "2019",
          "campus_statuses" => [
            {
              "campus_code" => "-",
              "name" => "Main Site",
              "vac_status" => nil,
              "publish" => nil,
              "status" => nil,
              "course_open_date" => nil,
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
            "institution_type" => "Y",
            "accrediting_provider" => nil
          },
          "accrediting_provider" => nil
        }
      ])
    end
  end
end
