# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PATCH /provider-onboarding/:uuid", type: :request do
  let(:submitted_request) { create(:providers_onboarding_form_request, :submitted) }

  it "returns 422 for a public user" do
    patch publish_provider_onboarding_path(submitted_request.uuid), params: { providers_onboarding_form_request: { provider_name: "New Name" } }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "returns 404 when UUID does not exist" do
    get publish_provider_onboarding_path("not-a-real-uuid")

    expect(response).to have_http_status(:not_found)
  end
end
