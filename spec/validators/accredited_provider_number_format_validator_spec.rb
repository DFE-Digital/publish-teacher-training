# frozen_string_literal: true

require "rails_helper"

class AccreditedProviderNumberFormatValidatorTest
  include ActiveModel::Validations

  attr_accessor :accredited_provider_number

  validates :accredited_provider_number, accredited_provider_number_format: { allow_blank: false }
end

describe AccreditedProviderNumberFormatValidator do
  let(:accredited_provider) { create(:accredited_provider, :university) }
  let(:accredited_provider_number) { 1234 }

  let(:model) do
    model = accredited_provider
    model.accredited_provider_number = accredited_provider_number
    model
  end

  describe "accredited university validation" do
    let(:accredited_provider) { create(:accredited_provider, :university) }

    context "with a 4 digit number starting with 1" do
      it "is valid" do
        expect(model).to be_valid
      end
    end

    context "with a 5 digit number starting with 1" do
      let(:accredited_provider_number) { 12_345 }

      it "is not valid" do
        expect(model).not_to be_valid
        expect(model.errors.messages[:accredited_provider_number]).to include("Enter a valid University accredited provider number - it must be 4 digits starting with a 1")
      end
    end

    context "with a number starting with 5" do
      let(:accredited_provider_number) { 5432 }

      it "is not valid" do
        expect(model).not_to be_valid
        expect(model.errors.messages[:accredited_provider_number]).to include("Enter a valid University accredited provider number - it must be 4 digits starting with a 1")
      end
    end
  end

  describe "accredited scitt validation" do
    let(:accredited_provider) { create(:accredited_provider, :scitt) }

    context "with a number starting with 1" do
      it "is not valid" do
        expect(model).not_to be_valid
        expect(model.errors.messages[:accredited_provider_number]).to include("Enter a valid SCITT accredited provider number - it must be 4 digits starting with a 5")
      end
    end

    context "with a 5 digit number starting with 5" do
      let(:accredited_provider_number) { 54_321 }

      it "is not valid" do
        expect(model).not_to be_valid
        expect(model.errors.messages[:accredited_provider_number]).to include("Enter a valid SCITT accredited provider number - it must be 4 digits starting with a 5")
      end
    end

    context "with a number starting with 5" do
      let(:accredited_provider_number) { 5432 }

      it "is valid" do
        expect(model).to be_valid
      end
    end
  end

  describe "lead school validation" do
    let(:accredited_provider) { create(:provider, accredited_provider_number: nil) }

    context "without an accredited_provider_number" do
      it "adds no errors" do
        model.valid?
        expect(model.errors).to be_empty
      end
    end
  end
end
