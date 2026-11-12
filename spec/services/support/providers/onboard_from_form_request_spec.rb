# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Providers::OnboardFromFormRequest do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:onboarding_request) { create(:providers_onboarding_form_request, :ready_to_onboard) }

  before { recruitment_cycle }

  describe ".call" do
    subject(:result) { described_class.call(onboarding_request:) }

    it "creates the provider and first user, then marks the request as onboarded" do
      expect(result).to be_success

      provider = result.provider
      expect(provider).to have_attributes(
        provider_name: "Northshore Training",
        provider_type: "lead_school",
        ukprn: onboarding_request.ukprn,
        urn: onboarding_request.urn,
        accredited: false,
        email: onboarding_request.contact_email_address,
        telephone: onboarding_request.telephone,
        website: onboarding_request.website,
        address1: onboarding_request.address_line_1,
        town: onboarding_request.town_or_city,
        address4: onboarding_request.county,
        postcode: onboarding_request.postcode,
        recruitment_cycle:,
      )
      expect(provider.provider_code).to match(Support::ProviderForm::PROVIDER_CODE_FORMAT)
      expect(provider.organisations.pluck(:name)).to eq(["Northshore Training"])
      expect(provider.users).to contain_exactly(
        have_attributes(
          email: onboarding_request.email_address.downcase,
          first_name: onboarding_request.first_name,
          last_name: onboarding_request.last_name,
        ),
      )
      expect(onboarding_request.reload).to be_onboarded
      expect(onboarding_request.provider).to eq(provider)
    end

    it "does not onboard the same request again" do
      first = described_class.call(onboarding_request:)

      second = described_class.call(onboarding_request: onboarding_request.reload)

      expect(second).not_to be_success
      expect(second.error_message).to eq("This provider has already been onboarded")
      expect(Provider.where(id: first.provider.id).count).to eq(1)
    end

    it "retries when the generated code is already used in the recruitment cycle" do
      create(:provider, recruitment_cycle:, provider_code: "Z99")
      allow(Support::Providers::ProviderCode).to receive(:call).and_return("Z99", "A1B")

      expect(result).to be_success
      expect(result.provider.provider_code).to eq("A1B")
    end

    it "can use a provider code that exists in another recruitment cycle" do
      other_cycle = create(:recruitment_cycle, :next)
      create(:provider, recruitment_cycle: other_cycle, provider_code: "A1B")
      allow(Support::Providers::ProviderCode).to receive(:call).and_return("A1B")

      expect(result).to be_success
      expect(result.provider.provider_code).to eq("A1B")
      expect(result.provider.recruitment_cycle).to eq(recruitment_cycle)
    end

    it "adds an existing user instead of creating another account" do
      existing_user = create(:user, email: "already.here@example.com", first_name: "Existing", last_name: "User")
      onboarding_request.update!(email_address: "already.here@example.com", first_name: "New", last_name: "Name")

      expect { result }.not_to change(User, :count)
      expect(result.provider.users).to contain_exactly(existing_user)
      expect(existing_user.reload).to have_attributes(first_name: "Existing", last_name: "User")
    end

    it "does not create a provider when the organisation details are invalid" do
      onboarding_request.update_column(:telephone, "bad")

      expect(result).not_to be_success
      expect(result.error_message).to include("Organisation details:").and include("Telephone")
      expect(Provider.find_by(provider_name: onboarding_request.provider_name)).to be_nil
      expect(onboarding_request.reload).to be_submitted
    end

    it "creates an accredited university" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: "1234",
        urn: nil,
      )

      expect(result).to be_success
      expect(result.provider).to have_attributes(
        provider_type: "university",
        accredited: true,
        accredited_provider_number: 1234,
        urn: nil,
      )
    end

    it "creates an accredited SCITT" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "scitt",
        accredited_provider_number: "5678",
        urn: nil,
      )

      expect(result).to be_success
      expect(result.provider).to have_attributes(
        provider_type: "scitt",
        accredited: true,
        accredited_provider_number: 5678,
      )
    end

    it "does not create an accredited school" do
      onboarding_request.update_columns(accredited_provider: true, accredited_provider_number: "1234")

      expect(result).not_to be_success
      expect(result.error_message).to include("Provider type school")
      expect(Provider.find_by(provider_name: onboarding_request.provider_name)).to be_nil
      expect(onboarding_request.reload).to be_submitted
    end

    it "does not onboard a request that has not been submitted" do
      pending_request = create(:providers_onboarding_form_request)

      outcome = described_class.call(onboarding_request: pending_request)

      expect(outcome).not_to be_success
      expect(outcome.error_message).to eq("This onboarding form has not been submitted, so the provider cannot be onboarded")
    end
  end
end
