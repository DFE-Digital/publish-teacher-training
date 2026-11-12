# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PATCH /provider-onboarding/:uuid", type: :request do
  include DfESignInUserHelper

  let(:submitted_request) { create(:providers_onboarding_form_request, :submitted) }
  let(:onboarding_request) { create(:providers_onboarding_form_request, :ready_to_onboard) }

  it "returns 422 for a public user" do
    patch publish_provider_onboarding_path(submitted_request.uuid), params: { providers_onboarding_form_request: { provider_name: "New Name" } }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "returns 404 when UUID does not exist" do
    get publish_provider_onboarding_path("not-a-real-uuid")

    expect(response).to have_http_status(:not_found)
  end

  it "returns an admin who came from the support page to that request" do
    login_user(create(:user, :admin))

    patch publish_provider_onboarding_path(onboarding_request.uuid), params: form_params(provider_name: "Updated Training").merge(return_to: "support")

    expect(response).to redirect_to(support_providers_onboarding_form_request_path(onboarding_request))
    expect(onboarding_request.reload.provider_name).to eq("Updated Training")
  end

  it "sends an admin who opened the form directly to check your answers" do
    login_user(create(:user, :admin))

    patch publish_provider_onboarding_path(onboarding_request.uuid), params: form_params(provider_name: "Updated Training")

    expect(response).to redirect_to(check_answers_publish_provider_onboarding_path(onboarding_request.uuid))
  end

  it "ignores a return address that is not the support token" do
    login_user(create(:user, :admin))

    patch publish_provider_onboarding_path(onboarding_request.uuid), params: form_params.merge(return_to: "https://evil.example")

    expect(response).to redirect_to(check_answers_publish_provider_onboarding_path(onboarding_request.uuid))
    expect(response.location).not_to include("evil.example")
  end

  it "does not send a public user to the support page" do
    pending_request = create(:providers_onboarding_form_request, :ready_to_onboard, status: "pending")

    patch publish_provider_onboarding_path(pending_request.uuid), params: form_params(request: pending_request).merge(return_to: "support")

    expect(response).to redirect_to(check_answers_publish_provider_onboarding_path(pending_request.uuid))
  end

  def form_params(request: onboarding_request, **overrides)
    {
      providers_onboarding_form_request: {
        provider_name: request.provider_name,
        email_address: request.email_address,
        first_name: request.first_name,
        last_name: request.last_name,
        address_line_1: request.address_line_1,
        town_or_city: request.town_or_city,
        postcode: request.postcode,
        telephone: request.telephone,
        contact_email_address: request.contact_email_address,
        website: request.website,
        ukprn: request.ukprn,
        accredited_provider: request.accredited_provider,
        provider_type: request.provider_type,
        urn: request.urn,
      }.merge(overrides),
    }
  end
end
