# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::StartDate do
  subject(:wizard_step) { wizard.current_step }

  include_context "add_course_wizard"

  let(:current_step) { :start_date }
  let(:provider_code) { provider.provider_code }
  let(:recruitment_cycle_year) { provider.recruitment_cycle_year }
  let(:current_step_params) { { start_date: } }
  let(:start_date) { nil }

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle, year: cycle_year) }
  let(:cycle_year) { Find::CycleTimetable.current_year }
  let(:provider) { create(:provider, :accredited_provider, recruitment_cycle:) }

  describe "#valid?" do
    context "when start_date is present" do
      it "is valid" do
        wizard_step.start_date = "January #{cycle_year}"
        expect(wizard_step).to be_valid
      end
    end

    context "when start_date is not present" do
      it "is not valid" do
        wizard_step.start_date = nil
        expect(wizard_step).not_to be_valid
        expect(wizard_step.errors.messages_for(:start_date)).to contain_exactly("Select a course start date")
      end
    end
  end

  # A cycle offers January of its year to July of the next, so where today sits
  # in that window decides what is still available. Routes admit the previous,
  # current and next cycles, which gives the cases below.
  describe "#start_date_options" do
    context "when the cycle has opened but its first month has not arrived" do
      # mid_cycle is two months after Find opens, which always falls in the
      # calendar year before the cycle year, so the whole window is still ahead.
      it "offers every month of the cycle", travel: mid_cycle do
        options = wizard_step.start_date_options

        expect(options.first).to eq("January #{cycle_year}")
        expect(options.last).to eq("July #{cycle_year + 1}")
      end
    end

    context "when today is inside the cycle's own year" do
      it "starts from the current month", travel: first_deadline_banner do
        options = wizard_step.start_date_options

        expect(options.first).to eq("July #{cycle_year}")
        expect(options.last).to eq("July #{cycle_year + 1}")
        expect(options).not_to include("June #{cycle_year}")
      end
    end

    context "when the cycle is the next one" do
      let(:cycle_year) { Find::CycleTimetable.next_year }

      it "offers every month of that cycle", travel: mid_cycle do
        options = wizard_step.start_date_options

        expect(options.first).to eq("January #{cycle_year}")
        expect(options.last).to eq("July #{cycle_year + 1}")
        expect(options).not_to include("December #{cycle_year - 1}")
      end
    end

    context "when the cycle has been superseded but its later months remain" do
      let(:cycle_year) { Find::CycleTimetable.previous_year }

      it "offers only the months that have not ended", travel: Time.zone.local(Find::CycleTimetable.current_year, 3, 1) do
        options = wizard_step.start_date_options

        expect(options.first).to eq("March #{cycle_year + 1}")
        expect(options.last).to eq("July #{cycle_year + 1}")
        expect(options).not_to include("January #{cycle_year}")
        expect(options).not_to include("February #{cycle_year + 1}")
      end
    end

    context "when every month of the cycle has passed" do
      let(:cycle_year) { Find::CycleTimetable.previous_year }

      it "offers the whole cycle rather than nothing", travel: Time.zone.local(Find::CycleTimetable.current_year, 8, 1) do
        options = wizard_step.start_date_options

        expect(options.first).to eq("January #{cycle_year}")
        expect(options.last).to eq("July #{cycle_year + 1}")
      end
    end

    context "when a start date has already been chosen" do
      let(:start_date) { "January #{cycle_year}" }

      it "keeps every month on offer so the chosen date stays selectable", travel: first_deadline_banner do
        options = wizard_step.start_date_options

        expect(options).to eq(Courses::CycleStartMonths.labels_for(cycle_year))
      end
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted params" do
      expect(described_class.permitted_params).to eq(%i[start_date])
    end
  end
end
