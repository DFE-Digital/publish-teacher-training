# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::CycleStartMonths do
  describe ".for" do
    subject(:months) { described_class.for(2026) }

    it "covers the whole cycle year and the first seven months of the next" do
      expect(months.size).to eq(19)
    end

    it "starts at January of the cycle year" do
      expect(months.first).to eq(Date.new(2026, 1, 1))
    end

    it "ends at July of the following year" do
      expect(months.last).to eq(Date.new(2027, 7, 1))
    end

    it "returns the first of each consecutive month" do
      expect(months).to eq((0..18).map { |offset| Date.new(2026, 1, 1) + offset.months })
    end

    it "accepts the year as a string" do
      expect(described_class.for("2026")).to eq(months)
    end
  end

  describe ".labels_for" do
    subject(:labels) { described_class.labels_for(2026) }

    it "labels each month with its name and year" do
      expect(labels.first).to eq("January 2026")
      expect(labels.last).to eq("July 2027")
    end

    it "has a label for every month" do
      expect(labels.size).to eq(described_class.for(2026).size)
    end
  end
end
