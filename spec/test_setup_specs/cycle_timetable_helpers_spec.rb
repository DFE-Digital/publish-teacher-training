# frozen_string_literal: true

require "rails_helper"

describe CycleTimetableHelpers do
  describe ".resolve_target_year" do
    it "returns nil when no year is given" do
      expect(described_class.resolve_target_year(nil)).to be_nil
      expect(described_class.resolve_target_year("")).to be_nil
    end

    it "returns the year it is given" do
      expect(described_class.resolve_target_year("2027")).to eq(2027)
    end

    it "resolves next to the year after the current cycle", travel: mid_cycle(2026) do
      expect(described_class.resolve_target_year("next")).to eq(2027)
    end

    it "rejects a year that is not in the cycle timetable" do
      expect { described_class.resolve_target_year("1999") }
        .to raise_error(ArgumentError, /TEST_CYCLE_YEAR=1999: 1999 is not a year in Find::CycleTimetable::CYCLE_DATES/)
    end

    it "names the year next resolves to when it is not in the cycle timetable" do
      allow(Find::CycleTimetable).to receive(:next_year).and_return(2099)

      expect { described_class.resolve_target_year("next") }
        .to raise_error(ArgumentError, /TEST_CYCLE_YEAR=next: 2099 is not a year in Find::CycleTimetable::CYCLE_DATES/)
    end

    it "rejects a value that is not a year" do
      expect { described_class.resolve_target_year("mid_cycle") }
        .to raise_error(ArgumentError, /TEST_CYCLE_YEAR=mid_cycle is not a year or "next"/)
    end
  end
end
