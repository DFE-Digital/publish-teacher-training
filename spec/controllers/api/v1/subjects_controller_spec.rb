require 'rails_helper'

RSpec.describe Api::V1::SubjectsController, type: :controller do
  before do
    controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials('bats')
    def controller.index
      raise PG::ConnectionBad
    end
  end

  describe "index" do
    it "render service unavailable" do
      get :index
      expect(response).to have_http_status(:service_unavailable)
      json = JSON.parse(response.body)
      expect(json). to eq(
        'code' => 503, 'status' => 'Service Unavailable'
      )
    end
  end
end
