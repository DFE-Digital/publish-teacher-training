require "rails_helper"

RSpec.describe "Subjecs API", type: :request do
  describe 'GET index' do
    before do
      FactoryBot.create_list(:subject, 10)
      get "/api/v1/subjects", headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bat", "beta") }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "JSON body response contains expected provider attributes" do
      json = JSON.parse(response.body)
      expect(json[0].keys).to match_array(%w[subject_name subject_code])
    end
  end
end
