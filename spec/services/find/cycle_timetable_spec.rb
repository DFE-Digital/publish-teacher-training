# frozen_string_literal: true

module Find
  require "rails_helper"

  RSpec.describe CycleTimetable do
    let(:one_hour_before_find_opens) { described_class.find_opens - 1.hour }
    let(:one_hour_after_find_opens) { described_class.find_opens + 1.hour }
    let(:one_hour_before_first_deadline_banner) { described_class.first_deadline_banner - 1.hour }
    let(:one_hour_before_apply_deadline) { described_class.apply_deadline - 1.hour }
    let(:one_hour_after_apply_deadline) { described_class.apply_deadline + 1.hour }
    let(:one_hour_after_find_closes) { described_class.find_closes + 1.hour }
    let(:one_hour_after_find_reopens) { described_class.find_reopens + 1.hour }

    describe ".current_year" do
      it "is 2021 if we are in the middle of the 2021 cycle" do
        Timecop.travel(Time.zone.local(2020, 10, 6, 10, 0, 0)) do
          expect(described_class.current_year).to eq(2021)
        end
      end

      it "is 2022 if we are in the middle of the 2022 cycle" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.current_year).to eq(2022)
        end
      end

      context "We are in the middle of the 2021 cycle and the cycle switcher has been set to 'apply has reopened'" do
        it "is 2022" do
          allow(SiteSetting).to receive(:cycle_schedule).and_return(:apply_reopened)

          Timecop.travel(Time.zone.local(2020, 10, 6, 10, 0, 0)) do
            expect(described_class.current_year).to eq(2022)
          end
        end
      end

      it "moves to the next cycle for every option past the rollover" do
        described_class::SWITCHER_OPTIONS.each do |option, definition|
          allow(SiteSetting).to receive(:cycle_schedule).and_return(option)

          real_year = described_class.cycle_year_for_time(Time.zone.now)
          expected = definition[:advances_cycle] ? real_year + 1 : real_year

          expect(described_class.current_year).to eq(expected), "wrong year for #{option}"
        end
      end
    end

    describe ".cycle_year_for_time" do
      it "returns 2026 for a time in the middle of the 2026 cycle" do
        time = Time.zone.local(2026, 1, 1, 12, 0, 0)
        expect(described_class.cycle_year_for_time(time)).to eq(2026)
      end

      it "returns 2027 for a time just after find closes 2026" do
        time = Time.zone.local(2026, 9, 29)
        expect(described_class.cycle_year_for_time(time)).to eq(2027)
      end

      it "returns 2027 for a time just before find opens 2027" do
        time = Time.zone.local(2026, 9, 29, 8, 59, 58)
        expect(described_class.cycle_year_for_time(time)).to eq(2027)
      end

      it "returns 2027 for the exact time find opens" do
        time = Time.zone.local(2026, 9, 29, 9, 0, 0)
        expect(described_class.cycle_year_for_time(time)).to eq(2027)
      end

      it "returns 2028 for the exact time find opens" do
        time = Time.zone.local(2027, 10, 5, 9, 0, 0)
        expect(described_class.cycle_year_for_time(time)).to eq(2028)
      end

      it "returns 2029 for the exact time find opens" do
        time = Time.zone.local(2028, 10, 3, 9, 0, 0)
        expect(described_class.cycle_year_for_time(time)).to eq(2029)
      end

      it "returns nil for a time before any defined cycle" do
        time = Time.zone.local(2019, 1, 1, 12, 0, 0)
        expect { described_class.cycle_year_for_time(time) }.to raise_error("NoRecruitmentCycleExists: time 2019-01-01 12:00:00")
      end

      # Taken from the last cycle rather than written out, so that adding the
      # next cycle moves the boundary instead of breaking this example.
      it "returns nil for a time after the last defined cycle" do
        time = described_class::CYCLE_DATES.values.last[:find_closes].end_of_day + 1.second

        expect { described_class.cycle_year_for_time(time) }.to raise_error("NoRecruitmentCycleExists: time #{time.utc.strftime('%Y-%m-%d %H:%M:%S')}")
      end
    end

    describe ".years_available_to_support" do
      context "when find opened 29 days ago" do
        it "returns last year", travel: 29.days.since(find_opens) do
          expect(described_class.years_available_to_support).to equal(described_class.previous_year)
        end
      end

      context "when find opened 30 days ago" do
        it "returns nil", travel: 30.days.since(find_opens) do
          expect(described_class.years_available_to_support).to be_nil
        end
      end
    end

    describe ".next_year" do
      it "is 2022 if we are in the middle of the 2021 cycle" do
        Timecop.travel(Time.zone.local(2021, 1, 1, 12, 0, 0)) do
          expect(described_class.next_year).to eq(2022)
        end
      end

      it "is 2023 if we are in the middle of the 2022 cycle" do
        Timecop.travel(Time.zone.local(2021, 11, 1, 12, 0, 0)) do
          expect(described_class.next_year).to eq(2023)
        end
      end
    end

    describe ".find_opens(year)" do
      context "when no argument is passed" do
        it "returns find_opens date for 2021" do
          Timecop.travel(Time.zone.local(2021, 1, 1, 12, 0, 0)) do
            expect(described_class.find_opens).to eq(Time.zone.local(2020, 10, 6, 9))
          end
        end
      end

      context "when passing 2024 as argument" do
        it "returns find_opens date for 2024" do
          Timecop.travel(Time.zone.local(2021, 11, 1, 12, 0, 0)) do
            expect(described_class.find_opens(2024)).to eq(Time.zone.local(2023, 10, 3, 9))
          end
        end
      end
    end

    describe ".preview_mode?" do
      it "returns true when it is after the Apply deadline but before Find closes" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.preview_mode?).to be true
        end
      end

      it "returns false before the Apply deadline" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.preview_mode?).to be false
        end
      end

      it "returns false when Find has reopened" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.preview_mode?).to be false
        end
      end
    end

    describe ".find_closed?" do
      it "returns true when it is after previous Find closes and before it opens" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 1, 0, 0)) do
          expect(described_class.find_closed?).to be true
        end
      end

      it "returns false before Find closes" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.find_closed?).to be false
        end
      end

      it "returns false when Find has reopened" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.find_closed?).to be false
        end
      end
    end

    describe ".can_create_application?" do
      it "returns true after Find has opened" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 10, 0, 0)) do
          expect(described_class.can_create_application?).to be true
        end
      end

      it "returns false after the apply_deadline" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.can_create_application?).to be false
        end
      end

      context "when current_cycle_schedule returns `:apply_open`" do
        it "returns true" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_open)
          expect(described_class.can_create_application?).to be true
        end
      end

      context "when current_cycle_schedule returns `:apply_not_open_yet`" do
        it "returns true, because a candidate can already build an application" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_not_open_yet)
          expect(described_class.can_create_application?).to be true
        end
      end

      context "when current_cycle_schedule returns `:apply_closed`" do
        it "returns false" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_closed)
          expect(described_class.can_create_application?).to be false
        end
      end
    end

    describe ".mid_cycle?" do
      it "returns true at the instant mid_cycle names" do
        Timecop.travel(described_class.mid_cycle(2022)) do
          expect(described_class.mid_cycle?).to be true
        end
      end

      it "returns false during the week before Apply opens" do
        Timecop.travel(described_class.find_opens(2022) + 1.hour) do
          expect(described_class.mid_cycle?).to be false
        end
      end

      it "returns false once the deadline banner is up" do
        Timecop.travel(described_class.first_deadline_banner(2022) + 1.day) do
          expect(described_class.mid_cycle?).to be false
        end
      end

      it "returns false after the apply deadline" do
        Timecop.travel(described_class.apply_deadline(2022) + 1.hour) do
          expect(described_class.mid_cycle?).to be false
        end
      end
    end

    describe ".show_apply_deadline_banner?" do
      context "when the switcher forces apply_open with the banner on" do
        it "returns true" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_open)
          allow(SiteSetting).to receive(:deadline_banner?).and_return(true)

          expect(described_class.show_apply_deadline_banner?).to be true
        end
      end

      context "when the switcher forces apply_open with the banner off" do
        it "returns false" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_open)
          allow(SiteSetting).to receive(:deadline_banner?).and_return(false)

          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end

      context "when the switcher forces a phase outside the apply window" do
        it "returns false even with the banner on" do
          allow(described_class).to receive(:current_cycle_schedule).and_return(:apply_closed)
          allow(SiteSetting).to receive(:deadline_banner?).and_return(true)

          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end

      it "returns true when it is after the first_deadline_banner and before the apply_deadline" do
        Timecop.travel(Time.zone.local(2024, 7, 30, 19, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be true
        end
      end

      it "returns false before the after the apply_deadline" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end

      it "returns false before the first_deadline_banner" do
        Timecop.travel(Time.zone.local(2021, 7, 7, 12, 0, 0)) do
          expect(described_class.show_apply_deadline_banner?).to be false
        end
      end
    end

    describe ".show_cycle_closed_banner?" do
      it "returns true when it is after the apply_deadline and before Find closes" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 19, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be true
        end
      end

      it "returns false after Find closes" do
        Timecop.travel(Time.zone.local(2021, 10, 5, 1, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be false
        end
      end

      it "returns false before the apply_deadline" do
        Timecop.travel(Time.zone.local(2021, 9, 21, 17, 0, 0)) do
          expect(described_class.show_cycle_closed_banner?).to be false
        end
      end
    end

    describe ".cycle_year_range" do
      it "returns the correctly formatted value" do
        Timecop.travel(Time.zone.local(2021, 9, 7, 17, 0, 0)) do
          expect(described_class.cycle_year_range).to eq("2021 to 2022")
        end
      end
    end

    describe ".next_cycle_year_range" do
      it "returns the correctly formatted value" do
        Timecop.travel(Time.zone.local(2021, 9, 7, 17, 0, 0)) do
          expect(described_class.next_cycle_year_range).to eq("2022 to 2023")
        end
      end
    end

    describe ".next_find_opens" do
      context "when find is closed in the 2025 cycle" do
        it "returns find_opens(2025)", travel: 1.hour.after(find_closes(2024)) do
          expect(described_class.next_find_opens).to eq(find_opens(2025))
        end
      end

      context "before find is closed in the 2024 cycle" do
        it "returns find_opens(2025)", travel: 1.hour.before(find_closes(2024)) do
          expect(described_class.next_find_opens).to eq(find_opens(2025))
        end
      end

      context "before find is closed in the 2050 cycle" do
        it "returns nil" do
          Timecop.travel(Time.zone.local(2050, 10, 10, 9)) do
            expect(described_class.next_find_opens).to be_nil
          end
        end
      end
    end

    describe ".current_or_previous_year?" do
      it "is true for the current cycle year" do
        expect(described_class.current_or_previous_year?(described_class.current_year)).to be(true)
      end

      it "is true for the previous cycle year" do
        expect(described_class.current_or_previous_year?(described_class.previous_year)).to be(true)
      end

      it "is false for the next cycle year" do
        expect(described_class.current_or_previous_year?(described_class.next_year)).to be(false)
      end

      it "is false for a year before the previous cycle" do
        expect(described_class.current_or_previous_year?(described_class.previous_year - 1)).to be(false)
      end

      it "accepts the year as a string" do
        expect(described_class.current_or_previous_year?(described_class.current_year.to_s)).to be(true)
      end
    end

    describe "CYCLE_DATES" do
      let(:cycles) { described_class::CYCLE_DATES }

      it "opens Apply one week after Find in every cycle" do
        offenders = cycles.reject { |_, dates| dates[:apply_opens].to_date == dates[:find_opens].to_date + 7 }

        expect(offenders.keys).to be_empty
      end

      it "closes Find the day before the next cycle opens" do
        offenders = cycles.reject do |year, dates|
          next_cycle = cycles[year + 1]
          next_cycle.nil? || dates[:find_closes].to_date + 1 == next_cycle[:find_opens].to_date
        end

        expect(offenders.keys).to be_empty
      end

      it "closes Find thirteen days after the Apply deadline" do
        offenders = cycles.reject do |_, dates|
          deadline = dates[:apply_deadline] || dates[:apply_1_deadline]
          dates[:find_closes].to_date == deadline.to_date + 13
        end

        expect(offenders.keys).to be_empty
      end

      it "sets the first deadline banner between Find opening and the Apply deadline" do
        offenders = cycles.reject do |_, dates|
          deadline = dates[:apply_deadline] || dates[:apply_1_deadline]
          dates[:first_deadline_banner].between?(dates[:find_opens], deadline)
        end

        expect(offenders.keys).to be_empty
      end
    end

    describe "PHASES" do
      it "holds every phase that phases_in_time answers for" do
        expect(described_class::PHASES.keys).to match_array(described_class.phases_in_time.keys)
      end

      it "runs apply_open for the whole apply window" do
        from, to = described_class.phase_range(:apply_open, 2026)

        expect(from).to eq(described_class.date(:apply_opens, 2026))
        expect(to).to eq(described_class.date(:apply_deadline, 2026))
      end

      it "tiles the cycle end to end, with no gap and no overlap" do
        ranges = described_class::PHASES.keys
          .map { |phase| described_class.phase_range(phase, 2026) }
          .sort_by(&:first)

        expect(ranges.each_cons(2).map { |(_, a_to), (b_from, _)| a_to == b_from }).to all(be true)
      end

      it "runs find_closed from Find closing in the previous cycle to Find reopening" do
        from, to = described_class.phase_range(:find_closed, 2027)

        expect(from).to eq(described_class.date(:find_closes, 2026))
        expect(to).to eq(described_class.date(:find_opens, 2027))
      end
    end

    describe ".year_for_option" do
      it "advances the year for an option past the rollover" do
        expect(described_class.year_for_option(:find_closed, 2026)).to eq(2027)
      end

      it "keeps the year for an option in the cycle running now" do
        expect(described_class.year_for_option(:apply_closed, 2026)).to eq(2026)
      end

      it "gives the same phase two years, one per option" do
        expect(described_class.phase_for_option(:apply_open)).to eq(:apply_open)
        expect(described_class.phase_for_option(:apply_reopened)).to eq(:apply_open)

        expect(described_class.year_for_option(:apply_open, 2026)).to eq(2026)
        expect(described_class.year_for_option(:apply_reopened, 2026)).to eq(2027)
      end

      it "defaults to the real cycle year for the current time when no year is given" do
        allow(described_class).to receive(:cycle_year_for_time).and_return(2026)

        expect(described_class.year_for_option(:apply_closed)).to eq(2026)
      end

      it "does not move when a different phase is selected in the switcher" do
        years_by_selection = described_class::SWITCHER_OPTIONS.keys.index_with do |selected|
          allow(SiteSetting).to receive(:cycle_schedule).and_return(selected)

          described_class::SWITCHER_OPTIONS.keys.index_with { |option| described_class.year_for_option(option) }
        end

        expect(years_by_selection.values.uniq.length).to eq(1)
      end
    end

    describe "the phase predicates" do
      it "turn on only the phase the switcher selects" do
        predicates = described_class::PHASES.keys.index_with { |phase| :"#{phase}?" }

        result = described_class::SWITCHER_OPTIONS.each_key.index_with do |selected|
          allow(described_class).to receive(:current_cycle_schedule).and_return(selected)

          predicates.select { |_, predicate| described_class.public_send(predicate) }.keys
        end

        expected = described_class::SWITCHER_OPTIONS.transform_values { |definition| [definition[:phase]] }
        expect(result).to eq(expected)
      end

      it "names one predicate for every phase" do
        expect(described_class::PHASES.keys).to all(satisfy { |phase| described_class.respond_to?(:"#{phase}?") })
      end
    end
  end
end
