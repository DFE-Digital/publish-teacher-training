# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::StartDateOptions do
  let(:year) { Find::CycleTimetable.current_year }

  describe "ALL" do
    it "lists the cycle year's buckets then the following year's" do
      expect(described_class::ALL).to eq(
        %w[jan_to_mar apr_to_jun jul_to_aug september oct_to_dec next_jan_to_mar next_apr_to_jun next_jul],
      )
    end
  end

  describe ".normalise" do
    it "keeps current values" do
      expect(described_class.normalise(%w[september next_jul])).to eq(%w[september next_jul])
    end

    it "expands jan_to_aug into January to August of the cycle year" do
      expect(described_class.normalise(%w[jan_to_aug])).to eq(%w[jan_to_mar apr_to_jun jul_to_aug])
    end

    it "expands oct_to_jul into October of the cycle year to July of the next" do
      expect(described_class.normalise(%w[oct_to_jul])).to eq(
        %w[oct_to_dec next_jan_to_mar next_apr_to_jun next_jul],
      )
    end

    it "returns values in display order without duplicates" do
      expect(described_class.normalise(%w[september jan_to_aug jan_to_mar])).to eq(
        %w[jan_to_mar apr_to_jun jul_to_aug september],
      )
    end

    it "drops unknown values" do
      expect(described_class.normalise(%w[september_2025 september])).to eq(%w[september])
    end

    it "returns an empty array for blank input" do
      expect(described_class.normalise(nil)).to eq([])
    end
  end

  describe ".ranges_for" do
    it "covers each bucket's months in the right year" do
      expect(described_class.ranges_for(described_class::ALL, year:)).to eq([
        Time.zone.local(year, 1, 1).beginning_of_month..Time.zone.local(year, 3, 1).end_of_month,
        Time.zone.local(year, 4, 1).beginning_of_month..Time.zone.local(year, 6, 1).end_of_month,
        Time.zone.local(year, 7, 1).beginning_of_month..Time.zone.local(year, 8, 1).end_of_month,
        Time.zone.local(year, 9, 1).beginning_of_month..Time.zone.local(year, 9, 1).end_of_month,
        Time.zone.local(year, 10, 1).beginning_of_month..Time.zone.local(year, 12, 1).end_of_month,
        Time.zone.local(year + 1, 1, 1).beginning_of_month..Time.zone.local(year + 1, 3, 1).end_of_month,
        Time.zone.local(year + 1, 4, 1).beginning_of_month..Time.zone.local(year + 1, 6, 1).end_of_month,
        Time.zone.local(year + 1, 7, 1).beginning_of_month..Time.zone.local(year + 1, 7, 1).end_of_month,
      ])
    end

    it "accepts legacy values" do
      expect(described_class.ranges_for(%w[jan_to_aug], year:).size).to eq(3)
    end

    it "returns no ranges for blank input" do
      expect(described_class.ranges_for([], year:)).to eq([])
    end
  end
end
