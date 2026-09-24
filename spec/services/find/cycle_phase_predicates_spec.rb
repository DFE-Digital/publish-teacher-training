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
      can_create_application: false,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: true,
      apply_soon_banner: false,
      year: 2026,
    },
    find_closed: {
      find_open: false,
      can_create_application: false,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2027,
    },
    apply_open: {
      find_open: true,
      can_create_application: true,
      mid_cycle: true,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2026,
    },
    apply_reopened: {
      find_open: true,
      can_create_application: true,
      mid_cycle: true,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: false,
      year: 2027,
    },
    apply_not_open_yet: {
      find_open: true,
      can_create_application: true,
      mid_cycle: false,
      deadline_banner: false,
      closed_banner: false,
      apply_soon_banner: true,
      year: 2027,
    },
    apply_closed: {
      find_open: true,
      can_create_application: false,
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
            can_create_application: Find::CycleTimetable.can_create_application?,
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
