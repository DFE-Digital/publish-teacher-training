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

  describe "#hint_for_option" do
    it "uses the phase's own boundaries" do
      allow(Find::CycleTimetable).to receive(:cycle_year_for_time).and_return(2026)

      hint = helper.hint_for_option(:apply_closed)

      expect(hint).to eq(
        "<strong>2026 cycle.</strong> Candidates can no longer submit any subsequent applications " \
        "(6pm on 15 September 2026 to 28 September 2026)",
      )
    end

    it "names the next cycle year and the closed window for find_closed" do
      allow(Find::CycleTimetable).to receive(:cycle_year_for_time).and_return(2026)

      hint = helper.hint_for_option(:find_closed)

      expect(hint).to eq(
        "<strong>2027 cycle.</strong> Candidates can no longer browse courses on Find " \
        "(11:59pm on 28 September 2026 to 29 September 2026)",
      )
    end
  end
end
