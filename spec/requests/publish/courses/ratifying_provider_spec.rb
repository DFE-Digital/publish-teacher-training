# frozen_string_literal: true

require "rails_helper"

describe "Publish::Courses::RatifyingProviderController#update", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user, :with_provider) }
  let(:provider) { user.providers.first }
  let!(:course) { create(:course, :unpublished, provider:, accrediting_provider: create(:accredited_provider)) }
  let(:path) { "/publish/organisations/#{provider.provider_code}/#{provider.recruitment_cycle_year}/courses/#{course.course_code}/ratifying-provider" }

  before { login_user(user) }

  context "when the form is submitted with no course params" do
    it "re-renders the form with a validation error instead of a server error" do
      create(:provider_partnership, training_provider: provider, accredited_provider: create(:accredited_provider))

      expect {
        put path, params: { commit: "Update accredited provider" }
      }.not_to(change { course.reload.accredited_provider_code })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select an accredited provider")
    end
  end

  context "when the provider has no accredited partnerships" do
    it "does not error when the empty form is submitted" do
      put path, params: {}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("You need to add an accredited provider before you can select one for this course.")
    end
  end
end
