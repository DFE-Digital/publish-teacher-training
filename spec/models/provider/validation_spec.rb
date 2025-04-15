# frozen_string_literal: true

require "rails_helper"

describe "validation" do
  let(:courses) { [] }
  let(:provider) do
    create(:provider,
           provider_name: "ACME SCITT",
           provider_code: "A01",
           courses:)
  end

  describe "update" do
    let(:provider) { build(:provider) }

    describe "email" do
      it "validates email is present" do
        provider.email = ""
        provider.valid? :update

        expect(provider.errors[:email]).to include("Enter an email address in the correct format, like name@example.com")
      end

      it "validates email contains an @ symbol" do
        provider.email = "meow"
        provider.valid? :update

        expect(provider.errors[:email]).to include("Enter an email address in the correct format, like name@example.com")
      end

      it "Does not validate the email if it is not present" do
        provider.website = "cats4lyf.cat"

        expect(provider.valid?(:update)).to be true
      end
    end

    describe "telephone" do
      it "validates telephone is present" do
        provider.telephone = ""
        provider.valid? :update

        expect(provider.errors[:telephone]).to include("Enter a telephone number")
      end

      it "Correctly validates valid phone numbers" do
        provider.telephone = "+447 123 123 123"
        expect(provider.valid?(:update)).to be true
      end

      it "Correctly invalidates invalid phone numbers" do
        provider.telephone = "123cat456"
        expect(provider.valid?(:update)).to be false
        expect(provider.errors[:telephone]).to include("Enter a telephone number, like 01632 960 001, 07700 900 982 or +44 0808 157 0192")
      end

      it "Correctly invalidates short phone numbers" do
        provider.telephone = "1234567"
        expect(provider.valid?(:update)).to be false
        expect(provider.errors[:telephone]).to include("Telephone number must contain 8 numbers or more")
      end

      it "Correctly invalidates long phone numbers" do
        provider.telephone = "123456791123456789"
        expect(provider.valid?(:update)).to be false
        expect(provider.errors[:telephone]).to include("Telephone number must contain 15 numbers or fewer")
      end

      it "Does not validate the telephone if it is not present" do
        provider.website = "cats4lyf.cat"

        expect(provider.valid?(:update)).to be true
      end
    end
  end

  describe "on update" do
    context "setting field to nil" do
      subject { provider }

      it { is_expected.to validate_presence_of(:train_with_us).on(:update) }
      it { is_expected.to validate_presence_of(:train_with_disability).on(:update) }
    end
  end

  describe "#train_with_us" do
    subject { build(:provider, train_with_us:) }

    let(:word_count) { 250 }
    let(:train_with_us) { Faker::Lorem.sentence(word_count:) }

    context "word count within limit" do
      it { is_expected.to be_valid }
    end

    context "word count exceed limit" do
      let(:word_count) { 250 + 1 }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#train_with_disability" do
    subject { build(:provider, train_with_disability:) }

    let(:word_count) { 250 }
    let(:train_with_disability) { Faker::Lorem.sentence(word_count:) }

    context "word count within limit" do
      it { is_expected.to be_valid }
    end

    context "word count exceed limit" do
      let(:word_count) { 250 + 1 }

      it { is_expected.not_to be_valid }
    end
  end
end
