require "spec_helper"

describe API::System::ApplicationController, type: :controller do
  let(:credentials) do
    ActionController::HttpAuthentication::Token
      .encode_credentials("Ge32")
  end

  let(:unauthorized_credentials) do
    ActionController::HttpAuthentication::Token
      .encode_credentials("Si14")
  end

  it "authenticates given the correct credentials" do
    request.headers["HTTP_AUTHORIZATION"] = credentials
    controller.response = response
    controller.authenticate
    expect(response).to have_http_status(:success)
  end

  it "does not authenticate given incorrect credentials" do
    controller.response = response
    request.headers["HTTP_AUTHORIZATION"] = unauthorized_credentials
    controller.authenticate
    expect(response).to have_http_status(:unauthorized)
  end
end
