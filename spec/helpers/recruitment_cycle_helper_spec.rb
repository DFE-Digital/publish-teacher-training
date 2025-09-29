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

    describe "#hint_text_for_mid_cycle" do
      it "returns text with correct dates" do
        expect(helper.hint_text_for_mid_cycle).to eq("Candidates can see upcoming application deadlines (9am on 1 October 2024 to 16 September 2025)")
      end
    end

    describe "#hint_text_for_after_apply_deadline_passed" do
      it "returns text with correct dates" do
        expect(helper.hint_text_for_after_apply_deadline_passed).to eq("Candidates can no longer submit any subsequent applications (16 September 2025 to 29 September 2025)")
      end
    end

    describe "#hint_text_for_now_is_before_find_opens" do
      it "returns text with correct dates" do
        expect(helper.hint_text_for_now_is_before_find_opens).to eq("Candidates can no longer browse courses on Find (11:59pm on 29 September 2025 to 9am on 30 September 2025)")
      end
    end

    describe "#hint_text_for_today_is_after_find_opens" do
      it "returns text with correct dates" do
        expect(helper.hint_text_for_today_is_after_find_opens).to eq("Candidates can browse courses on Find. Courses returned are from the next recruitment cycle (30 September 2025)")
      end
    end

    describe "#hint_text_for_today_is_between_find_opening_and_apply_opening" do
      it "returns text with correct dates" do
        expect(helper.hint_text_for_today_is_between_find_opening_and_apply_opening).to eq("Candidates are able to apply for the courses in the new cycle. (30 September 2025)")
      end
    end
  end
end
