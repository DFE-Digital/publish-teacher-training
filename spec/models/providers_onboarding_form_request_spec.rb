require "rails_helper"

RSpec.describe ProvidersOnboardingFormRequest, type: :model do
  describe "validations" do
    subject { build(:providers_onboarding_form_request) }

    before { create(:providers_onboarding_form_request) } # for uniqueness validation

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:form_name) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:provider_name) }
    it { is_expected.to validate_presence_of(:address_line_1) }
    it { is_expected.to validate_presence_of(:town_or_city) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_inclusion_of(:accredited_provider).in_array([true, false]) }
    it { is_expected.to belong_to(:support_agent).class_name("User").optional }

    it "raises an error when status is not in the enum keys" do
      expect {
        described_class.new(status: "invalid_status")
      }.to raise_error(ArgumentError, /'invalid_status' is not a valid status/)
    end

    it "allows valid status values" do
      expect {
        described_class.new(status: "pending")
      }.not_to raise_error
    end

    it "adds an error if support agent is not an admin user" do
      subject.support_agent = create(:user, admin: false)
      expect(subject).not_to be_valid
      expect(subject.errors[:support_agent]).to include("must be an admin user")
    end

    context "format validations" do
      context "UKPRN" do
        it "rejects invalid UKPRN" do
          subject.ukprn = "98765432"
          expect(subject).not_to be_valid
        end

        it "accepts valid UKPRN" do
          subject.ukprn = "12345678"
          expect(subject).to be_valid
        end
      end

      context "postcode" do
        it "rejects invalid postcode" do
          subject.postcode = "INVALID"
          expect(subject).not_to be_valid
        end

        it "accepts valid postcode" do
          subject.postcode = "BN1 1AA"
          expect(subject).to be_valid
        end
      end

      context "telephone" do
        it "rejects invalid telephone" do
          subject.telephone = "INVALID"
          expect(subject).not_to be_valid
        end

        it "accepts valid telephone" do
          subject.telephone = "+441234567890"
          expect(subject).to be_valid
        end
      end

      context "email addresses" do
        it "rejects invalid email addresses" do
          subject.email_address = "invalid_email"
          subject.contact_email_address = "also_invalid"
          expect(subject).not_to be_valid
        end

        it "accepts valid email addresses" do
          subject.email_address = "teacher123@provider.org"
          subject.contact_email_address = "provider@ittprovider.co.uk"
          expect(subject).to be_valid
        end
      end

      context "URN" do
        it "rejects URN that is too short" do
          subject.urn = "1234"
          expect(subject).not_to be_valid
        end

        it "accepts URN that is 6 digits" do
          subject.urn = "123456"
          expect(subject).to be_valid
        end
      end

      context "provider website" do
        it "accepts a valid provider website URL" do
          subject.website = "https://www.provider.org"
          expect(subject).to be_valid
        end

        it "rejects an invalid provider website URL" do
          subject.website = "www.provider.org"
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
