# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt do
  include_context "add_course_wizard"

  let(:current_step) { :visa_sponsorship_application_deadline_at }
  let(:visa_sponsorship_application_deadline_at) { nil }
  let(:wizard_step) { wizard.current_step }

  describe "#valid?" do
    it "is valid when visa_sponsorship_application_deadline_at is in range" do
      valid_date = Find::CycleTimetable.date(:apply_deadline, recruitment_cycle_year).to_date - 1.day
      set_date_parts(valid_date.year.to_s, valid_date.month.to_s, valid_date.day.to_s)

      expect(wizard_step).to be_valid
    end

    it "is invalid when all date fields are blank" do
      set_date_parts("", "", "")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("Select a date that applications close for visa sponsored candidates")
    end

    it "is invalid when some date fields are blank" do
      set_date_parts("2026", "", "1")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("The date that applications which require visa sponsorship will close must contain a day, a month and a year")
    end

    it "is invalid when date fields contain non-numeric values" do
      set_date_parts("abcd", "1", "2")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("The date that applications which require visa sponsorship will close can only contain numbers 0 to 9")
    end

    it "is invalid when date fields contain mixed numeric and non-numeric values" do
      set_date_parts("2026", "1a", "2")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("The date that applications which require visa sponsorship will close can only contain numbers 0 to 9")
    end

    it "is invalid when date is not real" do
      set_date_parts("2026", "2", "31")

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("Enter a real date that applications close for visa sponsored candidates")
    end

    it "is invalid when date is outside recruitment cycle range" do
      invalid_date = Find::CycleTimetable.date(:apply_deadline, recruitment_cycle_year).to_date + 1.day
      set_date_parts(invalid_date.year.to_s, invalid_date.month.to_s, invalid_date.day.to_s)

      expect(wizard_step).not_to be_valid
      expect(wizard_step.errors.messages_for(:visa_sponsorship_application_deadline_at))
        .to include("The date that applications which require visa sponsorship will close must be between today and the end of the recruitment cycle, 6pm on 15 September 2026\n")
    end
  end

private

  def set_date_parts(year, month, day)
    wizard_step.public_send("visa_sponsorship_application_deadline_at(1i)=", year)
    wizard_step.public_send("visa_sponsorship_application_deadline_at(2i)=", month)
    wizard_step.public_send("visa_sponsorship_application_deadline_at(3i)=", day)
  end
end
