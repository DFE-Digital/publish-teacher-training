# frozen_string_literal: true

require "rails_helper"

RSpec.describe ALevelsWizard::StateStores::ALevelStore do
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

  describe "#subject" do
    let(:repository) { instance_double(ALevelsWizard::Repositories::ALevelSubjectRemovalRepository, record: course, uuid: "abc123") }

    context "when the subject is a predefined option" do
      let(:a_level_subject_requirements) do
        [{ "uuid" => "abc123", "subject" => "any_subject", "minimum_grade_required" => "A" }]
      end

      it "returns the translated subject name" do
        expect(store.subject).to eq("Any subject")
      end
    end

    context "when the subject is other_subject with other_subject text" do
      let(:a_level_subject_requirements) do
        [{ "uuid" => "abc123", "subject" => "other_subject", "other_subject" => "Biology", "minimum_grade_required" => "A" }]
      end

      it "returns the other_subject text" do
        expect(store.subject).to eq("Biology")
      end
    end

    context "when the subject is other_subject with blank other_subject text" do
      let(:a_level_subject_requirements) do
        [{ "uuid" => "abc123", "subject" => "other_subject", "other_subject" => "", "minimum_grade_required" => "A" }]
      end

      it "falls back to the translated subject name" do
        expect(store.subject).to eq("Choose a subject")
      end
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
