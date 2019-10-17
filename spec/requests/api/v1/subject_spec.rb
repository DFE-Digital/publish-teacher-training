require "rails_helper"

describe "Subjecs API", type: :request do
  describe "GET index" do
    let(:current_cycle) { find_or_create :recruitment_cycle }
    let(:current_year)  { current_cycle.year.to_i }

    before do
      find_or_create(:secondary_subject, :modern_languages)
      find_or_create(:secondary_subject, :english)
      find_or_create(:modern_languages_subject, :french)
      find_or_create(:primary_subject, :primary)
      find_or_create(:further_education_subject)
      find_or_create(:discontinued_subject, :humanities)
    end

    it "returns http success" do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("bats") }
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized" do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("foo") }
      expect(response).to have_http_status(:unauthorized)
    end

    it "JSON body response contains expected provider attributes", without_subjects: true do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("bats") }

      json = JSON.parse(response.body)
      expect(json).to eq([
          {
            "subject_name" => "English",
            "subject_code" => "Q3",
            "type" => "SecondarySubject",
          },
          {
            "subject_name" => "French",
            "subject_code" => "15",
            "type" => "ModernLanguagesSubject",
          },
          {
            "subject_name" => "Primary",
            "subject_code" => "00",
            "type" => "PrimarySubject",
          },
          {
            "subject_name" => "Further education",
            "subject_code" => "41",
            "type" => "FurtherEducationSubject",
          },
        ])
    end
  end
end
