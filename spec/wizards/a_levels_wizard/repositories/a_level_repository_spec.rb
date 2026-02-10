# frozen_string_literal: true

require "rails_helper"

RSpec.describe ALevelsWizard::Repositories::ALevelRepository do
  subject(:repository) { described_class.new(record: course) }

  let(:course) do
    create(
      :course,
      accept_pending_a_level: true,
      a_level_subject_requirements: [
        { "uuid" => "abc123", "subject" => "any_subject", "minimum_grade_required" => "A" },
      ],
    )
  end

  describe "#transform_for_read" do
    it "converts accept_pending_a_level boolean to pending_a_level string 'yes'" do
      result = repository.transform_for_read({ accept_pending_a_level: true })
      expect(result[:pending_a_level]).to eq("yes")
    end

    it "converts accept_pending_a_level boolean to pending_a_level string 'no'" do
      result = repository.transform_for_read({ accept_pending_a_level: false })
      expect(result[:pending_a_level]).to eq("no")
    end

    it "converts accept_a_level_equivalency boolean to string 'yes'" do
      result = repository.transform_for_read({ accept_a_level_equivalency: true })
      expect(result[:accept_a_level_equivalency]).to eq("yes")
    end

    it "converts accept_a_level_equivalency boolean to string 'no'" do
      result = repository.transform_for_read({ accept_a_level_equivalency: false })
      expect(result[:accept_a_level_equivalency]).to eq("no")
    end

    it "merges virtual attributes" do
      repository.transform_for_write({ add_another_a_level: "yes" })
      result = repository.transform_for_read({})
      expect(result[:add_another_a_level]).to eq("yes")
    end
  end

  describe "#transform_for_write" do
    it "extracts virtual attributes" do
      repository.transform_for_write({ add_another_a_level: "yes", confirmation: "yes" })
      expect(repository.virtual_attributes).to eq({ add_another_a_level: "yes", confirmation: "yes" })
    end

    it "removes virtual attributes from output" do
      result = repository.transform_for_write({ add_another_a_level: "yes", subject: "any_subject" })
      expect(result).not_to have_key(:add_another_a_level)
      expect(result[:subject]).to eq("any_subject")
    end

    it "converts pending_a_level string 'yes' to accept_pending_a_level boolean true" do
      result = repository.transform_for_write({ pending_a_level: "yes" })
      expect(result[:accept_pending_a_level]).to be(true)
    end

    it "converts pending_a_level string 'no' to accept_pending_a_level boolean false" do
      result = repository.transform_for_write({ pending_a_level: "no" })
      expect(result[:accept_pending_a_level]).to be(false)
    end

    it "does not transform pending_a_level when nil" do
      result = repository.transform_for_write({ pending_a_level: nil })
      expect(result).not_to have_key(:accept_pending_a_level)
    end

    it "converts accept_a_level_equivalency string 'yes' to boolean true" do
      result = repository.transform_for_write({ accept_a_level_equivalency: "yes" })
      expect(result[:accept_a_level_equivalency]).to be(true)
    end

    it "converts accept_a_level_equivalency string 'no' to boolean false" do
      result = repository.transform_for_write({ accept_a_level_equivalency: "no" })
      expect(result[:accept_a_level_equivalency]).to be(false)
    end

    it "does not transform accept_a_level_equivalency when nil" do
      result = repository.transform_for_write({ accept_a_level_equivalency: nil })
      expect(result).not_to have_key(:accept_a_level_equivalency)
    end
  end

  describe "#excluded_columns" do
    it "returns uuid" do
      expect(repository.excluded_columns).to eq([:uuid])
    end
  end
end
