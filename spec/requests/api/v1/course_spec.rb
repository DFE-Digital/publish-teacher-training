require "rails_helper"

RSpec.describe "Courses API", type: :request do
  describe 'GET index' do
    before do
      FactoryBot.create(:course,
        course_code: "2HPF",
        name: "Religious Education",
        qualification: 1,
        provider: FactoryBot.create(:provider,
          provider_name: "ACME SCITT",
          provider_code: "2LD",
          site_count: 0,
          course_count: 0))

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
