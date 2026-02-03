# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repositories::ALevelSubjectRemovalRepository do
  subject(:repository) { described_class.new(record: course, uuid: uuid) }

  let(:course) { create(:course, a_level_subject_requirements: existing_requirements) }
  let(:existing_requirements) do
    [
      { "uuid" => "uuid-1", "subject" => "any_subject", "minimum_grade_required" => "A" },
      { "uuid" => "uuid-2", "subject" => "any_stem_subject", "minimum_grade_required" => "B" },
    ]
  end
  let(:uuid) { "uuid-1" }

  describe "#transform_for_write" do
    context "when confirmation is 'yes'" do
      it "removes the subject with matching uuid" do
        result = repository.transform_for_write({ confirmation: "yes" })

        expect(result[:a_level_subject_requirements]).to eq([
          { "uuid" => "uuid-2", "subject" => "any_stem_subject", "minimum_grade_required" => "B" },
        ])
      end
    end

    context "when confirmation is 'no'" do
      it "returns an empty hash without modifying requirements" do
        result = repository.transform_for_write({ confirmation: "no" })
        expect(result).to eq({})
      end
    end

    context "when removing the last subject" do
      let(:existing_requirements) do
        [{ "uuid" => "uuid-1", "subject" => "any_subject", "minimum_grade_required" => "A" }]
      end

      it "returns an empty array" do
        result = repository.transform_for_write({ confirmation: "yes" })
        expect(result[:a_level_subject_requirements]).to eq([])
      end
    end
  end

  describe "#transform_for_read" do
    it "returns an empty hash" do
      result = repository.transform_for_read({})
      expect(result).to eq({})
    end
  end
end
