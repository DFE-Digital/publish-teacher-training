# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Repositories::Course do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:repository) do
    described_class.new(
      provider_code: "PROV",
      recruitment_cycle_year: 2026,
      state_key: "test-state-key",
      expires_in: 24.hours,
      cache:,
    )
  end

  describe "#write / #read" do
    it "keeps a single symbol key when merging string-keyed step writes" do
      repository.write({ "level" => "secondary" })
      repository.write({ "is_send" => "false" })
      repository.write({ "primary_master_subject_id" => "56" })
      repository.write({ "secondary_master_subject_id" => "12", "subordinate_subject_id" => "34" })
      repository.write({ "age_range_in_years" => "11_to_16" })
      repository.write({ "course_age_range_in_years_other_from" => "1", "course_age_range_in_years_other_to" => "16" })
      repository.write({ "qualification" => "qts" })
      repository.write({ "funding_type" => "fee" })
      repository.write({ "study_pattern" => %w[full_time part_time] })
      repository.write({ "site_ids" => %w[1 2] })

      data = repository.read
      expect(data[:level]).to eq("secondary")
      expect(data[:is_send]).to eq("false")
      expect(data[:primary_master_subject_id]).to eq("56")
      expect(data[:secondary_master_subject_id]).to eq("12")
      expect(data[:subordinate_subject_id]).to eq("34")
      expect(data[:age_range_in_years]).to eq("11_to_16")
      expect(data[:course_age_range_in_years_other_from]).to eq("1")
      expect(data[:course_age_range_in_years_other_to]).to eq("16")
      expect(data[:qualification]).to eq("qts")
      expect(data[:funding_type]).to eq("fee")
      expect(data[:study_pattern]).to eq(%w[full_time part_time])
      expect(data[:site_ids]).to eq(%w[1 2])

      expect(data.keys.map(&:class).uniq).to eq([Symbol])
    end
  end
end
