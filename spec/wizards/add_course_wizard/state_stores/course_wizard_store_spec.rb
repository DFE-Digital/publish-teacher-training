# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::StateStores::CourseWizardStore do
  subject(:store) { described_class.new(repository:, attribute_names: %w[level qualification]) }

  let(:repository) { instance_double(DfE::Wizard::Repository::InMemory) }

  describe "#further_education_level?" do
    before do
      allow(repository).to receive(:read).and_return({ level: })
    end

    context "when level is 'further_education'" do
      let(:level) { "further_education" }

      it "returns true" do
        expect(store.further_education_level?).to be true
      end
    end

    context "when level is not 'further_education'" do
      let(:level) { "primary" }

      it "returns false" do
        expect(store.further_education_level?).to be false
      end
    end
  end

  describe "#primary_level?" do
    before do
      allow(repository).to receive(:read).and_return({ level: })
    end

    context "when level is 'primary'" do
      let(:level) { "primary" }

      it "returns true" do
        expect(store.primary_level?).to be true
      end
    end

    context "when level is not 'primary'" do
      let(:level) { "secondary" }

      it "returns false" do
        expect(store.primary_level?).to be false
      end
    end
  end

  describe "#undergraduate_degree_with_qts?" do
    before do
      allow(repository).to receive(:read).and_return({ qualification: })
    end

    context "when qualification is 'undergraduate_degree_with_qts'" do
      let(:qualification) { "undergraduate_degree_with_qts" }

      it "returns true" do
        expect(store.undergraduate_degree_with_qts?).to be true
      end
    end

    context "when qualification is not 'undergraduate_degree_with_qts'" do
      let(:qualification) { "qts" }

      it "returns false" do
        expect(store.undergraduate_degree_with_qts?).to be false
      end
    end
  end
end
