# frozen_string_literal: true

require "rails_helper"

module Publish
  describe ProviderSkilledWorkerVisaForm, type: :model do
    let(:params) { {} }
    let(:provider) { build(:provider, can_sponsor_skilled_worker_visa: nil) }

    subject { described_class.new(provider, params:) }

    describe "validations" do
      before { subject.valid? }

      it "validates can_sponsor_skilled_worker_visa" do
        expect(subject.errors[:can_sponsor_skilled_worker_visa]).to include("Select if candidates can get a sponsored Skilled Worker visa")
      end
    end

    describe "#save!" do
      let(:provider) { build(:provider, can_sponsor_skilled_worker_visa: nil) }
      let(:params) { { can_sponsor_skilled_worker_visa: true } }

      it "saves the provider with any new attributes" do
        expect { subject.save! }.to change(provider, :can_sponsor_skilled_worker_visa).from(nil).to(true)
      end
    end
  end
end
