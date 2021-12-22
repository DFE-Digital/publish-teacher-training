require "rails_helper"

class ReferenceNumberFormatValidatorTest
  include ActiveModel::Validations

  attr_accessor :reference_number

  validates :reference_number, reference_number_format: { allow_blank: true, maximum: 8, minimum: 8, message: "error" }
end

describe ReferenceNumberFormatValidator do
  let(:reference_number) { "12345678" }

  let(:model) do
    model = ReferenceNumberFormatValidatorTest.new
    model.reference_number = reference_number
    model
  end

  describe "reference number validation" do
    context "with a valid reference number" do
      it "does not add an error" do
        expect(model).to be_valid
      end
    end

    context "without a reference number" do
      let(:reference_number) { nil }

      it "does not add an error" do
        expect(model).to be_valid
      end
    end

    context "with a short reference number" do
      let(:reference_number) { "1234567" }

      it "adds an error" do
        expect(model).to be_invalid
        expect(model.errors[:reference_number]).to contain_exactly("error")
      end
    end

    context "with a long reference number" do
      let(:reference_number) { "123456789" }

      it "adds an error" do
        expect(model).to be_invalid
        expect(model.errors[:reference_number]).to contain_exactly("error")
      end
    end

    context "with a reference number containing letters" do
      let(:reference_number) { "SSSSSSSS" }

      it "adds an error" do
        expect(model).to be_invalid
        expect(model.errors[:reference_number]).to contain_exactly("error")
      end
    end
  end
end
