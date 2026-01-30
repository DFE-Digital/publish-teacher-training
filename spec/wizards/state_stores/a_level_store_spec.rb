# frozen_string_literal: true

require "rails_helper"

RSpec.describe StateStores::ALevelStore do
  subject(:store) { described_class.new(repository:) }

  let(:course) { create(:course, a_level_subject_requirements:) }
  let(:a_level_subject_requirements) { [] }
  let(:repository) { instance_double(DfE::Wizard::Repository::Model, record: course) }

  describe "#subjects" do
    let(:a_level_subject_requirements) do
      [
        { "uuid" => "abc123", "subject" => "any_subject", "minimum_grade_required" => "A" },
      ]
    end

    it "returns the a_level_subject_requirements from the repository record" do
      expect(store.subjects).to eq(a_level_subject_requirements)
    end
  end

  describe "#another_a_level_needed?" do
    subject(:store) { described_class.new(repository:, attribute_names: %w[add_another_a_level]) }

    before do
      allow(repository).to receive(:read).and_return({ add_another_a_level: })
    end

    context "when add_another_a_level is 'yes'" do
      let(:add_another_a_level) { "yes" }

      it "returns true" do
        expect(store.another_a_level_needed?).to be true
      end
    end

    context "when add_another_a_level is 'no'" do
      let(:add_another_a_level) { "no" }

      it "returns false" do
        expect(store.another_a_level_needed?).to be false
      end
    end

    context "when add_another_a_level is nil" do
      let(:add_another_a_level) { nil }

      it "returns false" do
        expect(store.another_a_level_needed?).to be false
      end
    end
  end
end
