# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Providers::OnboardFromFormRequest do
  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:onboarding_request) { create(:providers_onboarding_form_request, :ready_to_onboard) }

  before { recruitment_cycle }

  describe ".call" do
    subject(:onboarded) { described_class.call(onboarding_request:) }

    let(:provider) { onboarding_request.provider }

    it "creates the provider and first user, then marks the request as onboarded" do
      expect(onboarded).to be(true)

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
      expect(onboarding_request.errors).to be_empty
    end

    it "does not onboard the same request again" do
      described_class.call(onboarding_request:)
      first_provider = onboarding_request.provider
      second_attempt = ProvidersOnboardingFormRequest.find(onboarding_request.id)

      expect(described_class.call(onboarding_request: second_attempt)).to be(false)
      expect(second_attempt.errors[:base]).to eq(["This provider has already been onboarded"])
      expect(Provider.where(provider_name: first_provider.provider_name).count).to eq(1)
    end

    it "retries when the generated code is already used in the recruitment cycle" do
      create(:provider, recruitment_cycle:, provider_code: "Z99")
      allow(Support::Providers::ProviderCode).to receive(:call).and_return("Z99", "A1B")

      expect(onboarded).to be(true)
      expect(provider.provider_code).to eq("A1B")
    end

    it "can use a provider code that exists in another recruitment cycle" do
      other_cycle = create(:recruitment_cycle, :next)
      create(:provider, recruitment_cycle: other_cycle, provider_code: "A1B")
      allow(Support::Providers::ProviderCode).to receive(:call).and_return("A1B")

      expect(onboarded).to be(true)
      expect(provider.provider_code).to eq("A1B")
      expect(provider.recruitment_cycle).to eq(recruitment_cycle)
    end

    it "does not grant the first user access to an unrelated next-cycle provider with the same code" do
      next_cycle = create(:recruitment_cycle, :next, available_in_publish_from: 1.day.ago)
      unrelated_provider = create(:provider, recruitment_cycle: next_cycle, provider_code: "A1B")
      accredited_provider = create(:provider, :accredited_provider, recruitment_cycle:)
      user = create(:user, email: onboarding_request.email_address.downcase)
      accredited_provider.users << user
      create(:user_notification, user:, provider: accredited_provider, course_publish: true, course_update: true)
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: "1234",
        urn: nil,
      )
      allow(Support::Providers::ProviderCode).to receive(:call).and_return("A1B")
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(NewUserAddedBySupportTeamMailer).to receive(:user_added_to_provider_email).and_return(mailer)

      expect(onboarded).to be(true)
      expect(provider.users).to contain_exactly(user)
      expect(unrelated_provider.reload.users).to be_empty
      expect(NewUserAddedBySupportTeamMailer).to have_received(:user_added_to_provider_email).with(recipient: user)
      expect(mailer).to have_received(:deliver_later)
      expect(UserNotification.where(user:, provider_code: "A1B", course_publish: true, course_update: true)).to exist
      expect(UserNotification.where(user:, provider_code: accredited_provider.provider_code, course_publish: true, course_update: true)).to exist
    end

    it "adds an existing user instead of creating another account" do
      existing_user = create(:user, email: "already.here@example.com", first_name: "Existing", last_name: "User")
      onboarding_request.update!(email_address: "already.here@example.com", first_name: "New", last_name: "Name")

      expect { onboarded }.not_to change(User, :count)
      expect(provider.users).to contain_exactly(existing_user)
      expect(existing_user.reload).to have_attributes(first_name: "Existing", last_name: "User")
    end

    it "does not create a provider when the organisation details are invalid" do
      onboarding_request.update_column(:telephone, "bad")

      expect(onboarded).to be(false)
      expect(onboarding_request.errors[:telephone]).to include(
        "Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192",
      )
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

      expect(onboarded).to be(true)
      expect(provider).to have_attributes(
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

      expect(onboarded).to be(true)
      expect(provider).to have_attributes(
        provider_type: "scitt",
        accredited: true,
        accredited_provider_number: 5678,
      )
    end

    it "does not create an accredited school" do
      onboarding_request.update_columns(accredited_provider: true, accredited_provider_number: "1234")

      expect(onboarded).to be(false)
      expect(onboarding_request.errors[:provider_type]).to include("Accredited provider cannot be a school")
      expect(Provider.find_by(provider_name: onboarding_request.provider_name)).to be_nil
      expect(onboarding_request.reload).to be_submitted
    end

    it "does not onboard a request that has not been submitted" do
      pending_request = create(:providers_onboarding_form_request)

      expect(described_class.call(onboarding_request: pending_request)).to be(false)
      expect(pending_request.errors[:base]).to eq(["This onboarding form has not been submitted, so the provider cannot be onboarded"])
      expect(pending_request.reload.provider).to be_nil
    end

    it "does not onboard an accredited provider without an accredited provider number" do
      onboarding_request.update!(
        accredited_provider: true,
        provider_type: "university",
        accredited_provider_number: nil,
        urn: nil,
      )

      expect(onboarded).to be(false)
      expect(onboarding_request.errors[:accredited_provider_number]).to eq(
        ["Enter a valid University accredited provider number - it must be 4 digits starting with a 1"],
      )
      expect(Provider.find_by(provider_name: onboarding_request.provider_name)).to be_nil
    end

    it "undoes the provider and puts the reason on base when the first user cannot be saved" do
      allow(User).to receive(:find_or_initialize_by).and_wrap_original do |original, **args|
        original.call(**args).tap do |user|
          allow(user).to receive(:save) do
            user.errors.add(:email, "^Email is not allowed")
            false
          end
        end
      end

      expect(onboarded).to be(false)
      expect(onboarding_request.errors[:base]).to eq(["This provider could not be onboarded. User details: Email is not allowed"])
      expect(Provider.find_by(provider_name: onboarding_request.provider_name)).to be_nil
      expect(onboarding_request.reload).to be_submitted
    end
  end
end
