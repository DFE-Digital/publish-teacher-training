# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find pages under each cycle phase", travel: Time.zone.local(2026, 9, 18, 12) do
  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
  end

  {
    real: {
      find_open: true,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: true,
      apply_soon_banner: false,
      year: 2026,
    },
    now_is_before_find_opens: {
      find_open: false,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2027,
    },
    today_is_after_find_opens: {
      find_open: true,
      mid_cycle: true,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2027,
    },
    today_is_between_find_opening_and_apply_opening: {
      find_open: true,
      mid_cycle: true,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: true,
      year: 2027,
    },
    today_is_mid_cycle: {
      find_open: true,
      mid_cycle: true,
      deadline_banner: true,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2026,
    },
    today_is_after_apply_deadline_passed: {
      find_open: true,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: true,
      apply_soon_banner: false,
      year: 2026,
    },
  }.each do |schedule, expected|
    context "when the cycle schedule is #{schedule}" do
      before { SiteSetting.set(name: "cycle_schedule", value: schedule) }

      it "records the predicates and the cycle year" do
        expect(
          {
            find_open: Find::CycleTimetable.find_open?,
            mid_cycle: Find::CycleTimetable.mid_cycle?,
            deadline_banner: Find::CycleTimetable.show_apply_deadline_banner?,
            closed_banner: Find::CycleTimetable.show_cycle_closed_banner?,
            apply_soon_banner: Find::CycleTimetable.show_apply_opens_soon_banner?,
            year: Find::CycleTimetable.current_year,
          },
        ).to eq(expected)
      end
    end
  end
end
