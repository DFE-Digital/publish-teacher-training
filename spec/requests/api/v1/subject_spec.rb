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
    end

    it "returns http success" do
      get "/api/v1/2019/subjects", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("bats") }
      expect(response).to have_http_status(:success)
    end

    it "returns http unauthorized" do
      get "/api/v1/2019/subjects", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("foo") }
      expect(response).to have_http_status(:unauthorized)
    end

    it "JSON body response contains expected provider attributes" do
      get "/api/v1/2019/subjects", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials("bats") }

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
