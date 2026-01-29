# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProvidersOnboardingFormRequest, type: :model do
  describe "validations" do
    subject { build(:providers_onboarding_form_request) }

    before { create(:providers_onboarding_form_request) } # for uniqueness validation

    # Unconditional validations (when support agent generates the form request)
    it { is_expected.to validate_presence_of(:form_name) }
    it { is_expected.to belong_to(:support_agent).class_name("User").optional }

    it "raises an error when status is not in the enum keys" do
      expect {
        described_class.new(status: "invalid_status")
      }.to raise_error(ArgumentError, /'invalid_status' is not a valid status/)
    end

    it "accepts valid zendesk link" do
      record = build(
        :providers_onboarding_form_request,
        zendesk_link: "https://becomingateacher.zendesk.com/agent/tickets/6789490",
      )

      expect(record).to be_valid
    end

    it "rejects invalid zendesk link" do
      record = build(
        :providers_onboarding_form_request,
        zendesk_link: "https://example-zendesk-link.com",
      )

      expect(record).not_to be_valid
      expect(record.errors[:zendesk_link]).to include("Must be a valid Zendesk URL")
    end

    it "has a UUID assigned by the database after create" do
      record = create(:providers_onboarding_form_request)
      expect(record.uuid).to be_present
    end

    # Conditional validations (when provider submits the form details)
    context "when status is submitted" do
      let(:record) { build(:providers_onboarding_form_request, :submitted) }

      it { is_expected.to validate_inclusion_of(:accredited_provider).in_array([true, false]) }

      it "requires all key provider details to be present" do
        record.first_name = nil
        record.last_name = nil
        record.email_address = nil
        record.provider_name = nil
        record.address_line_1 = nil
        record.town_or_city = nil
        record.postcode = nil
        record.telephone = nil
        record.contact_email_address = nil
        record.website = nil
        record.ukprn = nil
        record.urn = nil
        expect(record).not_to be_valid
        expect(record.errors[:first_name]).to be_present
        expect(record.errors[:last_name]).to be_present
        expect(record.errors[:email_address]).to be_present
        expect(record.errors[:provider_name]).to be_present
        expect(record.errors[:address_line_1]).to be_present
        expect(record.errors[:town_or_city]).to be_present
        expect(record.errors[:postcode]).to be_present
        expect(record.errors[:telephone]).to be_present
        expect(record.errors[:contact_email_address]).to be_present
        expect(record.errors[:website]).to be_present
        expect(record.errors[:ukprn]).to be_present
        expect(record.errors[:urn]).to be_present
      end

      context "format validations" do
        it "rejects invalid UKPRN" do
          record.ukprn = "98765432"
          expect(record).not_to be_valid
          expect(record.errors[:ukprn]).to include("Enter a valid UK provider reference number (UKPRN) - it must be 8 digits starting with a 1, like 12345678")
        end

        it "accepts valid UKPRN" do
          record.ukprn = "12345678"
          expect(record).to be_valid
        end

        it "rejects invalid postcode" do
          record.postcode = "INVALID"
          expect(record).not_to be_valid
          expect(record.errors[:postcode]).to include("Postcode is not valid, (for example, BN1 1AA)")
        end

        it "accepts valid postcode" do
          record.postcode = "BN1 1AA"
          expect(record).to be_valid
        end

        it "rejects invalid telephone" do
          record.telephone = "INVALID"
          expect(record).not_to be_valid
          expect(record.errors[:telephone]).to include("Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192")
        end

        it "accepts valid telephone" do
          record.telephone = "+441234567890"
          expect(record).to be_valid
        end

        it "rejects invalid email addresses" do
          record.email_address = "invalid_email"
          record.contact_email_address = "also_invalid"
          expect(record).not_to be_valid
          expect(record.errors[:email_address]).to include("Enter an email address in the correct format, like name@example.com")
        end

        it "accepts valid email addresses" do
          record.email_address = "teacher123@provider.org"
          record.contact_email_address = "provider@ittprovider.co.uk"
          expect(record).to be_valid
        end

        it "rejects URN that is too short" do
          record.urn = "1234"
          expect(record).not_to be_valid
          expect(record.errors[:urn]).to include("Provider URN must be 5 or 6 numbers")
        end

        it "rejects URN that is too long" do
          record.urn = "1234567"
          expect(record).not_to be_valid
          expect(record.errors[:urn]).to include("Provider URN must be 5 or 6 numbers")
        end

        it "accepts URN that is 6 digits" do
          record.urn = "123456"
          expect(record).to be_valid
        end

        it "accepts a valid provider website URL" do
          record.website = "https://www.provider.org"
          expect(record).to be_valid
        end

        it "rejects an invalid provider website URL" do
          record.website = "www.provider.org"
          expect(record).not_to be_valid
          expect(record.errors[:website]).to include("Enter a website address in the correct format, like https://www.example.com")
        end
      end

      # Custom validation for support agent being an admin user
      context "Non-admin support agent" do
        let(:non_admin_user) { create(:user, admin: false) }
        let(:record) { build(:providers_onboarding_form_request, support_agent: non_admin_user) }

        it "is not valid and adds an error on support_agent" do
          expect(record).not_to be_valid
          expect(record.errors[:support_agent]).to include("must be an admin user")
        end
      end

      context "Support agent is an admin user" do
        let(:admin_user) { create(:user, admin: true, email: "admin@education.gov.uk") }
        let(:record) { build(:providers_onboarding_form_request, support_agent: admin_user) }

        it "is valid" do
          expect(record).to be_valid
        end
      end
    end
  end

  context "when validate_provider_fields is true on a pending record" do
    let(:record) { build(:providers_onboarding_form_request, :validate_provider_fields) }

    it "runs provider validations even though status is pending" do
      record.provider_name = nil
      record.postcode = nil

      expect(record).not_to be_valid
      expect(record.errors[:provider_name]).to include("Enter your organisation name")
      expect(record.errors[:postcode]).to be_present
    end
  end

  describe "#form_link" do
    let(:request) { create(:providers_onboarding_form_request) }

    it "returns the publish provider onboarding URL for the uuid" do
      expected_url =
        Rails.application.routes.url_helpers.publish_provider_onboarding_url(uuid: request.uuid)

      expect(request.form_link).to eq(expected_url)
    end
  end
end
