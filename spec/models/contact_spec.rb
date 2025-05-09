# frozen_string_literal: true

require "rails_helper"

describe Contact do
  it { is_expected.to belong_to(:provider) }

  describe "type" do
    it "is an enum" do
      expect(subject)
        .to define_enum_for(:type)
        .backed_by_column_of_type(:text)
        .with_values(
          admin: "admin",
          utt: "utt",
          web_link: "web_link",
          fraud: "fraud",
          finance: "finance",
        )
        .with_suffix("contact")
    end
  end

  describe "on update" do
    let(:provider) { create(:provider, contacts:, changed_at: 5.minutes.ago) }
    let(:contacts) { [build(:contact)] }
    let(:contact) { contacts.first }

    before do
      provider
    end

    it "touches the provider" do
      contacts.first.save
      expect(provider.reload.changed_at).to be_within(1.second).of Time.now.utc
    end

    it { is_expected.to validate_presence_of(:name) }

    describe "telephone" do
      it "validates telephone is present" do
        contact.telephone = ""
        contact.valid?

        expect(contact.errors[:telephone]).to include("Enter a telephone number")
      end

      it "Correctly validates valid phone numbers" do
        contact.telephone = "+447 123 123 123"
        expect(contact.valid?).to be true
      end

      it "Correctly invalidates invalid phone numbers" do
        contact.telephone = "123foo456"
        expect(contact.valid?).to be false
        expect(contact.errors[:telephone]).to include("Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192")
      end

      it "Correctly invalidates short phone numbers" do
        contact.telephone = "1234567"
        expect(contact.valid?).to be false
        expect(contact.errors[:telephone]).to include("Telephone number must contain 8 numbers or more")
      end

      it "Correctly invalidates long phone numbers" do
        contact.telephone = "123456791123456789"
        expect(contact.valid?).to be false
        expect(contact.errors[:telephone]).to include("Telephone number must contain 15 numbers or fewer")
      end
    end

    describe "email" do
      it "validates email is present" do
        contact.email = ""
        contact.valid?

        expect(contact.errors[:email]).to include("Enter an email address in the correct format, like name@example.com")
      end

      it "validates email contains an @ symbol" do
        contact.email = "bar"
        contact.valid?

        expect(contact.errors[:email]).to include("Enter an email address in the correct format, like name@example.com")
      end

      it "Does not validate the email if it is present" do
        contact.email = "foo@bar.com"

        expect(contact.valid?).to be true
      end
    end

    describe "permission_given" do
      subject { build(:contact, permission_given: permission_given_value) }

      context "true" do
        let(:permission_given_value) { true }

        it { is_expected.to be_valid }
      end

      context "false" do
        let(:permission_given_value) { false }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
