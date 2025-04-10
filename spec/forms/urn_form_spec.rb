# frozen_string_literal: true

require "rails_helper"

describe URNForm, type: :model do
  subject { described_class.new(provider, params:) }

  let(:provider) { create(:provider) }
  let(:params) { { values: "y,r,u,a,pain" } }

  describe "validations" do
    before { subject.validate }

    context "blank values" do
      let(:params) { { values: nil } }

      it "is invalid" do
        expect(subject.errors[:values]).to include("Enter URNs")
        expect(subject.valid?).to be(false)
      end
    end

    context "valid params" do
      it "is valid" do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe "#stash" do
    context "valid details" do
      it "returns true" do
        expect(subject.stash).to be true

        expect(subject.errors.messages).to be_blank
      end
    end
  end
end
