# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::CycleBranch do
  describe ".current_or_previous?" do
    it "is true for the current cycle year" do
      expect(described_class.current_or_previous?(Find::CycleTimetable.current_year)).to be(true)
    end

    it "is true for the previous cycle year" do
      expect(described_class.current_or_previous?(Find::CycleTimetable.previous_year)).to be(true)
    end

    it "is false for the next cycle year" do
      expect(described_class.current_or_previous?(Find::CycleTimetable.next_year)).to be(false)
    end

    it "is false for a year before the previous cycle" do
      expect(described_class.current_or_previous?(Find::CycleTimetable.previous_year - 1)).to be(false)
    end

    it "accepts the year as a string" do
      expect(described_class.current_or_previous?(Find::CycleTimetable.current_year.to_s)).to be(true)
    end
  end
end
