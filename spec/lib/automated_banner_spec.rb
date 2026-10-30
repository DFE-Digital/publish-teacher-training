# frozen_string_literal: true

require "rails_helper"

RSpec.describe AutomatedBanner do
  def next_year = Find::CycleTimetable.current_year + 1

  def banner(id) = described_class.all.find { it.id == id }

  def date(name, year = Find::CycleTimetable.current_year, format: :day_and_month)
    Find::CycleTimetable.public_send(name, year).to_fs(format)
  end

  def enable_cycle_switcher
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
  end

  describe "apply deadline soon" do
    it "is scheduled for the first deadline banner date", travel: 1.hour.before(first_deadline_banner) do
      expect(described_class.scheduled.map(&:id)).to include("apply_deadline_soon")
      expect(banner("apply_deadline_soon")).to have_attributes(
        published_at: Find::CycleTimetable.first_deadline_banner,
        expired_at: Find::CycleTimetable.apply_deadline,
      )
    end

    it "is active on Find until the deadline", travel: 1.hour.after(first_deadline_banner) do
      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_deadline_soon])
    end

    it "moves to the next cycle once the deadline has passed", travel: 1.hour.after(apply_deadline) do
      expect(banner("apply_deadline_soon").published_at).to eq(Find::CycleTimetable.first_deadline_banner(next_year))
    end

    it "names the deadline", travel: 1.hour.after(first_deadline_banner) do
      expect(banner("apply_deadline_soon")).to have_attributes(
        heading: "The deadline for applying to courses starting in the #{Find::CycleTimetable.cycle_year_range} academic year is #{date(:apply_deadline, format: :govuk_date_and_time)}",
        body: "Courses may fill up before then. Check course availability with the provider.",
      )
    end

    it "is active when the cycle switcher turns the deadline banner on", travel: mid_cycle do
      enable_cycle_switcher
      SiteSetting.set(name: "cycle_schedule", value: "apply_open")
      SiteSetting.set(name: "deadline_banner", value: "true")

      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_deadline_soon])
    end
  end

  describe "apply closed" do
    it "is scheduled for the deadline", travel: 1.hour.before(apply_deadline) do
      expect(described_class.scheduled.map(&:id)).to include("apply_closed")
      expect(banner("apply_closed")).to have_attributes(
        published_at: Find::CycleTimetable.apply_deadline,
        expired_at: Find::CycleTimetable.find_closes,
      )
    end

    it "is active on Find once the deadline has passed", travel: 1.hour.after(apply_deadline) do
      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_closed])
      expect(described_class.active(interface: :publish)).to be_empty
    end

    it "is gone once Find has closed", travel: 1.hour.after(find_closes) do
      expect(described_class.active(interface: :find)).to be_empty
    end

    it "says when the next cycle opens", travel: 1.hour.after(apply_deadline) do
      expect(banner("apply_closed")).to have_attributes(
        heading: "The application deadline has passed",
        body: <<~BODY.chomp,
          The application deadline has passed for courses starting in the #{Find::CycleTimetable.cycle_year_range} academic year.

          From #{date(:find_opens, next_year)} you will be able to search for courses starting in the #{Find::CycleTimetable.next_cycle_year_range} academic year. From #{date(:apply_opens, next_year)} you will be able to apply for these courses.
        BODY
      )
    end

    it "is absent while the next cycle has no dates", travel: 1.hour.after(apply_deadline) do
      stub_const("Find::CycleTimetable::CYCLE_DATES", Find::CycleTimetable::CYCLE_DATES.except(next_year))

      expect(banner("apply_closed")).to be_nil
    end

    it "is active when the cycle switcher says Apply has closed", travel: mid_cycle do
      enable_cycle_switcher
      SiteSetting.set(name: "cycle_schedule", value: "apply_closed")

      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_closed])
    end
  end

  describe "apply opens soon" do
    it "is scheduled for the moment Find opens", travel: 1.hour.before(find_opens) do
      expect(described_class.scheduled.map(&:id)).to include("apply_opens_soon")
      expect(banner("apply_opens_soon")).to have_attributes(
        published_at: Find::CycleTimetable.find_opens,
        expired_at: Find::CycleTimetable.apply_opens,
      )
    end

    it "is active on Find until Apply opens", travel: 1.hour.after(find_opens) do
      expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_opens_soon])
      expect(described_class.active(interface: :publish)).to be_empty
    end

    it "moves to the next cycle once Apply has opened", travel: 1.hour.after(apply_opens) do
      expect(described_class.active(interface: :find)).to be_empty
      expect(banner("apply_opens_soon").published_at).to eq(Find::CycleTimetable.find_opens(next_year))
    end

    it "says when Apply opens", travel: 1.hour.after(find_opens) do
      expect(banner("apply_opens_soon")).to have_attributes(
        heading: "Apply for courses from #{date(:apply_opens)}",
        body: <<~BODY.chomp,
          The application deadline has passed for courses starting in the #{Find::CycleTimetable.cycle_year_range(Find::CycleTimetable.current_year - 1)} academic year.

          You can now search for courses starting in the #{Find::CycleTimetable.cycle_year_range} academic year. You can prepare applications for these courses, and from #{date(:apply_opens)} you will be able to submit your applications.
        BODY
      )
    end

    it "renders in the last cycle the timetable has dates for", travel: 1.hour.after(find_opens) do
      stub_const("Find::CycleTimetable::CYCLE_DATES", Find::CycleTimetable::CYCLE_DATES.except(next_year))

      expect(banner("apply_opens_soon").body).to include("from #{date(:apply_opens)}")
    end

    context "when the cycle switcher is on" do
      before { enable_cycle_switcher }

      it "is active on Find when the cycle switcher says Apply has not opened", travel: 1.hour.after(apply_opens) do
        SiteSetting.set(name: "cycle_schedule", value: "apply_not_open_yet")

        expect(described_class.active(interface: :find).map(&:id)).to eq(%w[apply_opens_soon])
      end

      it "is inactive when the cycle switcher says Apply is open", travel: 1.hour.after(find_opens) do
        SiteSetting.set(name: "cycle_schedule", value: "apply_open")

        expect(described_class.active(interface: :find)).to be_empty
      end
    end
  end

  describe "rollover has started" do
    def rollover_started = banner("rollover_started")

    let!(:next_cycle) { find_or_create(:recruitment_cycle, :next) }

    it "is scheduled for the day rollover is available to providers" do
      expect(described_class.scheduled.map(&:id)).to include("rollover_started")
      expect(rollover_started).to have_attributes(
        published_at: next_cycle.available_in_publish_from.in_time_zone.beginning_of_day,
        expired_at: Find::CycleTimetable.find_opens(next_year),
      )
    end

    it "is active on Publish until Find opens for the new cycle" do
      travel_to next_cycle.available_in_publish_from.in_time_zone.beginning_of_day do
        expect(described_class.active(interface: :publish).map(&:id)).to eq(%w[rollover_started])
        expect(described_class.active(interface: :find).map(&:id)).not_to include("rollover_started")
      end
    end

    it "stays active through the night before Find opens" do
      travel_to 1.hour.before(Find::CycleTimetable.find_opens(next_year)) do
        expect(described_class.active(interface: :publish).map(&:id)).to eq(%w[rollover_started])
      end
    end

    it "is gone once Find has opened" do
      travel_to 1.hour.after(Find::CycleTimetable.find_opens(next_year)) do
        expect(rollover_started).to be_nil
      end
    end

    it "is absent while the next cycle has no rollover date" do
      next_cycle.update!(available_in_publish_from: nil)

      expect(rollover_started).to be_nil
    end

    it "asks providers to schedule their courses before Find opens" do
      find_opens = Find::CycleTimetable.find_opens(next_year)

      expect(rollover_started).to have_attributes(
        heading: "Action required by #{(find_opens - 1.day).to_fs(:day_and_month)}: check and schedule your courses",
        body: <<~BODY.chomp,
          Courses for the #{next_cycle.year_range} recruitment cycle will be published on [Find teacher training courses](#{Settings.find_url}) on #{find_opens.to_fs(:day_and_month)}. Before this, you need to check and schedule your rolled over courses. If you do not schedule your courses, candidates will not be able to see them when Find opens.

          Read [guidance on rolling over courses to a new recruitment cycle](/how-to-use-this-service/roll-over-courses-to-a-new-recruitment-cycle) if you need help.
        BODY
      )
    end
  end

  it "refuses an id it does not know" do
    expect { described_class.find("nonsense") }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
