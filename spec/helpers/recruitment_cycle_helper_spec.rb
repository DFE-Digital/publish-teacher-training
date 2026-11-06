require "rails_helper"

RSpec.describe RecruitmentCycleHelper do
  describe "current cycle is 2025 - 2026", travel: mid_cycle(2025) do
    describe "#current_recruitment_cycle_period_text" do
      it "returns 2024 to 2025" do
        expect(helper.current_recruitment_cycle_period_text).to eq("2024 to 2025")
      end
    end

    describe "#next_recruitment_cycle_period_text" do
      it "returns 2025 to 2026" do
        expect(helper.next_recruitment_cycle_period_text).to eq("2025 to 2026")
      end
    end

    describe "#previous_recruitment_cycle_period_text" do
      it "returns 2023 to 2024" do
        expect(helper.previous_recruitment_cycle_period_text).to eq("2023 to 2024")
      end
    end
  end

  describe "cycle switcher content", travel: mid_cycle(2026) do
    before do
      allow(Find::CycleTimetable).to receive(:cycle_year_for_time).and_return(2026)
    end

    describe "#switcher_option_label" do
      it "puts the date range on the label and keeps the year on both dates when the range spans years" do
        expect(helper.switcher_option_label(:apply_open)).to eq(
          "Find and Apply open<span class=\"govuk-hint govuk-!-margin-bottom-0\"> - 7 October 2025 to 15 September 2026</span>",
        )
      end

      it "drops the year from the start date when both dates are in the same year" do
        expect(helper.switcher_option_label(:apply_closed)).to eq(
          "Find open, Apply closed<span class=\"govuk-hint govuk-!-margin-bottom-0\"> - 15 September to 28 September 2026</span>",
        )
      end

      it "describes Find and Apply closed from the end of the current cycle" do
        expect(helper.switcher_option_label(:find_closed)).to eq(
          "Find and Apply closed<span class=\"govuk-hint govuk-!-margin-bottom-0\"> - 28 September to 29 September 2026</span>",
        )
      end

      it "describes the next cycle opening before Apply" do
        expect(helper.switcher_option_label(:apply_not_open_yet)).to eq(
          "Find open, Apply closed<span class=\"govuk-hint govuk-!-margin-bottom-0\"> - 29 September to 6 October 2026</span>",
        )
      end

      it "describes Find and Apply opening in the next cycle" do
        expect(helper.switcher_option_label(:apply_reopened)).to eq(
          "Find and Apply open<span class=\"govuk-hint govuk-!-margin-bottom-0\"> - 6 October 2026 to 21 September 2027</span>",
        )
      end
    end

    describe "#switcher_cycle_group_heading" do
      it "names the current recruitment cycle" do
        expect(helper.switcher_cycle_group_heading(:apply_open)).to eq(
          "2025-2026 recruitment cycle - current",
        )
      end

      it "names the next recruitment cycle" do
        expect(helper.switcher_cycle_group_heading(:apply_not_open_yet)).to eq(
          "2026-2027 recruitment cycle",
        )
      end
    end
  end
end
