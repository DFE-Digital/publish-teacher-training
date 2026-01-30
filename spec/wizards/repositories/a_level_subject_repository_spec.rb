# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repositories::ALevelSubjectRepository do
  subject(:repository) { described_class.new(record: course, uuid: uuid) }

  let(:course) { create(:course, a_level_subject_requirements: existing_requirements) }
  let(:existing_requirements) { [] }
  let(:uuid) { nil }

  describe "#transform_for_write" do
    context "when creating a new A level subject requirement" do
      let(:uuid) { "new-uuid-123" }
      let(:existing_requirements) { [] }

      it "appends the new subject to the array" do
        result = repository.transform_for_write({
          uuid: "new-uuid-123",
          subject: "any_subject",
          minimum_grade_required: "A",
        })

        expect(result[:a_level_subject_requirements]).to eq([
          { "uuid" => "new-uuid-123", "subject" => "any_subject", "minimum_grade_required" => "A" },
        ])
      end
    end

    context "when adding to existing A level subject requirements" do
      let(:uuid) { "new-uuid-456" }
      let(:existing_requirements) do
        [{ "uuid" => "existing-uuid", "subject" => "any_subject", "minimum_grade_required" => "B" }]
      end

      it "appends the new subject while preserving existing ones" do
        result = repository.transform_for_write({
          uuid: "new-uuid-456",
          subject: "any_stem_subject",
          minimum_grade_required: "C",
        })

        expect(result[:a_level_subject_requirements]).to eq([
          { "uuid" => "existing-uuid", "subject" => "any_subject", "minimum_grade_required" => "B" },
          { "uuid" => "new-uuid-456", "subject" => "any_stem_subject", "minimum_grade_required" => "C" },
        ])
      end
    end

    context "when updating an existing A level subject requirement" do
      let(:uuid) { "existing-uuid" }
      let(:existing_requirements) do
        [
          { "uuid" => "existing-uuid", "subject" => "any_subject", "minimum_grade_required" => "B" },
          { "uuid" => "other-uuid", "subject" => "any_stem_subject", "minimum_grade_required" => "C" },
        ]
      end

      it "updates the matching subject and preserves others" do
        result = repository.transform_for_write({
          uuid: "existing-uuid",
          subject: "other_subject",
          other_subject: "Mathematics",
          minimum_grade_required: "A",
        })

        expect(result[:a_level_subject_requirements]).to eq([
          { "uuid" => "existing-uuid", "subject" => "other_subject", "other_subject" => "Mathematics", "minimum_grade_required" => "A" },
          { "uuid" => "other-uuid", "subject" => "any_stem_subject", "minimum_grade_required" => "C" },
        ])
      end
    end

    context "when updating from other_subject to any_subject" do
      let(:uuid) { "existing-uuid" }
      let(:existing_requirements) do
        [{ "uuid" => "existing-uuid", "subject" => "other_subject", "other_subject" => "Mathematics" }]
      end

      it "removes other_subject field when changing subject type" do
        result = repository.transform_for_write({
          uuid: "existing-uuid",
          subject: "any_subject",
          minimum_grade_required: "D",
        })

        expect(result[:a_level_subject_requirements]).to eq([
          { "uuid" => "existing-uuid", "subject" => "any_subject", "minimum_grade_required" => "D" },
        ])
      end
    end
  end

  describe "#transform_for_read" do
    let(:existing_requirements) do
      [
        { "uuid" => "abc123", "subject" => "any_subject", "minimum_grade_required" => "A" },
        { "uuid" => "def456", "subject" => "any_stem_subject", "minimum_grade_required" => "B" },
      ]
    end

    context "when uuid is present" do
      let(:uuid) { "abc123" }

      it "returns the matching A level subject requirement" do
        result = repository.transform_for_read({})
        expect(result).to eq({ "uuid" => "abc123", "subject" => "any_subject", "minimum_grade_required" => "A" })
      end
    end

    context "when uuid is blank" do
      let(:uuid) { nil }

      it "returns an empty hash" do
        result = repository.transform_for_read({})
        expect(result).to eq({})
      end
    end
  end
end
