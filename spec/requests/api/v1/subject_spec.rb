require "rails_helper"

RSpec.describe "Subjecs API", type: :request do
  describe 'GET index' do
    before do
      FactoryBot.create(:subject,
        subject_name: "Mathematics",
        subject_code: "B1")
      FactoryBot.create(:subject,
        subject_name: "Biology",
        subject_code: "M4")

      get "/api/v1/subjects", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bat", "beta") }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "JSON body response contains expected provider attributes" do
      json = JSON.parse(response.body)
      expect(json).to eq([
        {
          "subject_name" => "Mathematics",
          "subject_code" => "B1",
        },
        {
          "subject_name" => "Biology",
          "subject_code" => "M4",
        },
      ])
    end
  end
end
