# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::RecruitmentCycleForm do
  describe "attribute assignment" do
    it "parses multi-parameter dates for application start date" do
      form = described_class.new(
        "application_start_date(1i)" => "2024",
        "application_start_date(2i)" => "09",
        "application_start_date(3i)" => "30",
      )
      expect(form.application_start_date).to eq(Date.new(2024, 9, 30))
    end

    it "parses multi-parameter dates for application end date" do
      form = described_class.new(
        "application_end_date(1i)" => "2025",
        "application_end_date(2i)" => "10",
        "application_end_date(3i)" => "2",
      )
      expect(form.application_end_date).to eq(Date.new(2025, 10, 2))
    end

    it "handles invalid dates gracefully" do
      form = described_class.new(
        "application_start_date(1i)" => "2025",
        "application_start_date(2i)" => "02",
        "application_start_date(3i)" => "30",
      )
      expect(form.application_start_date).to be_nil
    end

    it "handles incomplete dates gracefully" do
      form = described_class.new(
        "application_start_date(1i)" => "",
        "application_start_date(2i)" => "",
        "application_start_date(3i)" => "",
      )
      expect(form.application_start_date).to be_nil
    end
  end

  describe "validations" do
    subject(:form) { described_class.new(params) }

    context "when required fields are missing" do
      let(:params) { {} }

      it "is invalid without a year" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("Enter a year")
      end

      it "is invalid without an application start date" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include("Enter the date that candidates will be able to start applying for courses")
      end

      it "is invalid without an application end date" do
        expect(form).not_to be_valid
        expect(form.errors[:application_end_date]).to include("Enter the date that applications close")
      end
    end

    context "when year is not a number" do
      let(:params) { { year: "twenty twenty five" } }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("Enter a number")
      end
    end

    context "when dates are valid" do
      let(:year) { Find::CycleTimetable.next_year }
      let(:apply_opens) { Find::CycleTimetable.apply_opens(year).to_date }
      let(:params) do
        {
          "year" => year.to_s,
          **date_params(:application_start_date, apply_opens),
          **date_params(:application_end_date, apply_opens + 5.months),
          **date_params(:available_in_publish_from, apply_opens - 1.month),
          **date_params(:available_for_support_users_from, apply_opens - 2.months),
        }
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when application start date does not match the Find cycle timetable" do
      let(:year) { Find::CycleTimetable.next_year }
      let(:apply_opens) { Find::CycleTimetable.apply_opens(year).to_date }
      let(:params) do
        {
          "year" => year.to_s,
          **date_params(:application_start_date, apply_opens + 1.day),
          **date_params(:application_end_date, apply_opens + 5.months),
          **date_params(:available_in_publish_from, apply_opens - 1.month),
          **date_params(:available_for_support_users_from, apply_opens - 2.months),
        }
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include(
          "Application start date must be #{apply_opens.to_fs(:govuk_date)}, which is the date in the Find cycle timetable. Update the timetable first if this date has changed.",
        )
      end
    end

    context "when the year is not in the Find cycle timetable" do
      let(:year) { Find::CycleTimetable::CYCLE_DATES.keys.max + 1 }
      let(:params) do
        {
          "year" => year.to_s,
          **date_params(:application_start_date, Date.new(year - 1, 10, 15)),
          **date_params(:application_end_date, Date.new(year, 3, 10)),
          **date_params(:available_in_publish_from, Date.new(year - 1, 9, 1)),
          **date_params(:available_for_support_users_from, Date.new(year - 1, 8, 1)),
        }
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include(
          "Add the recruitment cycle to the Find cycle timetable before setting the application start date",
        )
      end
    end

    context "when end date is before start date" do
      let(:params) do
        {
          "year" => "2025",
          "application_start_date(1i)" => "2025",
          "application_start_date(2i)" => "03",
          "application_start_date(3i)" => "15",
          "application_end_date(1i)" => "2025",
          "application_end_date(2i)" => "03",
          "application_end_date(3i)" => "10",
        }
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include("Start date must be before the application end date")
        expect(form.errors[:application_end_date]).to include("End date must be after the application start date")
      end
    end

    context "when dates are invalid" do
      let(:params) do
        {
          "year" => "2025",
          "application_start_date(1i)" => "2025",
          "application_start_date(2i)" => "02",
          "application_start_date(3i)" => "30",
          "application_end_date(1i)" => "2025",
          "application_end_date(2i)" => "03",
          "application_end_date(3i)" => "50",
          "available_for_support_users_from(1i)" => "2025",
          "available_for_support_users_from(2i)" => "03",
          "available_for_support_users_from(3i)" => "50",
        }
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include("Enter a valid date")
        expect(form.errors[:application_end_date]).to include("Enter a valid date")
        expect(form.errors[:available_for_support_users_from]).to include("Enter a valid date")
      end
    end

    context "when available_for_support_users_from is not before available_in_publish_from" do
      let(:params) do
        {
          "available_for_support_users_from(1i)" => "2026",
          "available_for_support_users_from(2i)" => "05",
          "available_for_support_users_from(3i)" => "01",
          "available_in_publish_from(1i)" => "2026",
          "available_in_publish_from(2i)" => "04",
          "available_in_publish_from(3i)" => "01",
        }
      end

      it "is invalid" do
        form = described_class.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:available_for_support_users_from]).to include(
          "Enter a date before the courses become available to providers in Publish.",
        )
        expect(form.errors[:available_in_publish_from]).to include(
          "Enter a date after the courses become available to support users",
        )
      end
    end

    context "when dates are incomplete" do
      let(:params) do
        {
          "year" => "2025",
          "application_start_date(1i)" => "2025",
          "application_start_date(2i)" => "02",
          "application_end_date(1i)" => "2025",
          "application_end_date(2i)" => "03",
          "application_end_date(3i)" => "10",
          "available_for_support_users_from(3i)" => "2025",
          "available_for_support_users_from(2i)" => "10",
        }
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include("Enter the date that candidates will be able to start applying for courses")
        expect(form.errors[:available_for_support_users_from]).to include("Enter the date when courses will become available to support users (in Publish and Support).")
      end
    end

    context "when year is not unique" do
      let(:params) { { year: } }
      let(:year) { 2025 }

      before do
        find_or_create(:recruitment_cycle, year:)
      end

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("Year has already been taken")
      end
    end
  end

  def date_params(attribute, date)
    {
      "#{attribute}(1i)" => date.year.to_s,
      "#{attribute}(2i)" => date.month.to_s,
      "#{attribute}(3i)" => date.day.to_s,
    }
  end
end
