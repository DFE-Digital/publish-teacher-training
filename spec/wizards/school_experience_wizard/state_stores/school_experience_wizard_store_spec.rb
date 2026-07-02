# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore do
  subject(:store) { described_class.new(repository:, attribute_names: %w[experience_required]) }

  let(:repository) { instance_double(SchoolExperienceWizard::Repositories::SchoolExperienceRepository) }

  describe "#experience_is_required?" do
    before do
      allow(repository).to receive(:read).and_return({ experience_required: })
    end

    context "when experience_required is true" do
      let(:experience_required) { true }

      it "returns true" do
        expect(store.experience_is_required?).to be true
      end
    end

    context "when experience_required is false" do
      let(:experience_required) { false }

      it "returns false" do
        expect(store.experience_is_required?).to be false
      end
    end

    context "when experience_required is nil" do
      let(:experience_required) { nil }

      it "returns nil" do
        expect(store.experience_is_required?).to be_nil
      end
    end
  end
end
