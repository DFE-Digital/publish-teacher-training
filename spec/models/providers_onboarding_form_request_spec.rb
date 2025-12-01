require "rails_helper"

RSpec.describe ProvidersOnboardingFormRequest, type: :model do
  describe "validations" do
    subject { build(:providers_onboarding_form_request) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:form_name) }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:organisation_name) }
    it { is_expected.to validate_presence_of(:address_line_1) }
    it { is_expected.to validate_presence_of(:town_or_city) }
    it { is_expected.to validate_presence_of(:postcode) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:contact_email_address) }
    it { is_expected.to validate_presence_of(:organisation_website) }
    it { is_expected.to validate_presence_of(:accredited_provider) }
    it { is_expected.to validate_presence_of(:ukprn) }
    it { is_expected.to validate_presence_of(:urn) }
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
  end
end
