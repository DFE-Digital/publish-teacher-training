# frozen_string_literal: true

require "rails_helper"

module Publish
  describe ProviderStudentVisaForm, type: :model do
    let(:params) { {} }
    let(:provider) { build(:provider, can_sponsor_student_visa: nil) }

    subject { described_class.new(provider, params:) }

    describe "validations" do
      before { subject.valid? }

      it "validates can_sponsor_student_visa" do
        expect(subject.errors[:can_sponsor_student_visa]).to include("Select if candidates can get a sponsored Student visa")
      end
    end

    describe "#save!" do
      let(:provider) { build(:provider, can_sponsor_student_visa: nil) }
      let(:params) { { can_sponsor_student_visa: true } }

      it "saves the provider with any new attributes" do
        expect { subject.save! }.to change(provider, :can_sponsor_student_visa).from(nil).to(true)
      end
    end
  end
end
