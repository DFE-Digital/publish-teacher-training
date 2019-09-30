require "rails_helper"

RSpec.describe "Subjecs API", type: :request do
  describe "GET index" do
    let(:current_cycle) { find_or_create :recruitment_cycle }
    let(:current_year)  { current_cycle.year.to_i }

    before do
      FactoryBot.find_or_create(:subject, :modern_languages)
      FactoryBot.find_or_create(:subject, :english)
      FactoryBot.find_or_create(:subject, :french)
      FactoryBot.find_or_create(:subject, :primary)
      FactoryBot.find_or_create(:subject, :further_education)
      FactoryBot.find_or_create(:subject, :humanities)
    end

    it "returns http success" do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("bats") }
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized" do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("foo") }
      expect(response).to have_http_status(:unauthorized)
    end

    it "JSON body response contains expected provider attributes" do
      get "/api/v1/#{current_year}/subjects", headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials("bats") }

      json = JSON.parse(response.body)
      expect(json).to eq([
          {
            "subject_name" => "English",
            "subject_code" => "E",
          },
          {
            "subject_name" => "French",
            "subject_code" => "F1",
          },
          {
            "subject_name" => "Primary",
            "subject_code" => "00",
          },
          {
            "subject_name" => "Further education",
            "subject_code" => "41",
          },
        ])
    end
  end
end
