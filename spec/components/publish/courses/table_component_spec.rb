# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::TableComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(courses:, provider:)) }

  let(:provider) { create(:provider) }
  # Rows carry the read-model columns (content_status, has_unpublished_changes), so
  # source them through the query exactly as the page does.
  let(:courses) { Publish::Courses::Query.call(provider: provider.reload).map(&:decorate) }

  it "renders the Course, Course information and Status column headers" do
    create(:course, :published_postgraduate, provider:)
    render_component

    headers = page.all(".govuk-table__header").map(&:text)
    expect(headers).to eq(["Course", "Course information", "Status"])
  end

  context "a course row" do
    before do
      create(:course, :published_postgraduate, provider:, name: "Biology", course_code: "B123", start_date: Time.zone.local(2026, 9, 1))
    end

    it "renders the course name and the age range hint" do
      render_component

      within(".app-table--courses__course-name") do
        expect(page).to have_text("Biology (B123)")
        expect(page).to have_css(".govuk-hint", text: "Ages 3 to 7")
      end
    end

    context "when the course is secondary" do
      before do
        create(:course, :secondary, :published_postgraduate, provider:, name: "Physics", course_code: "P456")
      end

      it "does not render the age range" do
        render_component

        expect(page).to have_text("Physics (P456)")
        expect(page).to have_no_text("Ages 11 to 18")
      end
    end

    it "renders the course information lines" do
      render_component

      within(".app-table--courses__course-information") do
        expect(page).to have_text("Fee-paying")
        expect(page).to have_text("QTS with PGCE")
        expect(page).to have_text("Full time")
        expect(page).to have_css('span.govuk-\!-font-size-16', text: "September 2026")
      end
    end

    it "renders the status tag" do
      render_component

      expect(page).to have_css(".govuk-tag", text: "Open")
    end
  end

  describe "funding label" do
    {
      fee: "Fee-paying",
      salary: "Salaried",
      apprenticeship: "Apprenticeship",
    }.each do |funding, label|
      it "renders #{label.inspect} for a #{funding} course" do
        create(:course, :skip_validate, provider:, funding:)
        render_component

        expect(page).to have_css(".app-table--courses__course-information", text: label)
      end
    end
  end

  describe "study type label" do
    {
      full_time: "Full time",
      part_time: "Part time",
      full_time_or_part_time: "Full time or part time",
    }.each do |study_mode, label|
      it "renders #{label.inspect} for a #{study_mode} course" do
        create(:course, :skip_validate, provider:, study_mode:)
        render_component

        expect(page).to have_css(".app-table--courses__course-information", text: label)
      end
    end
  end

  context "when a course has no start date" do
    before { create(:course, :skip_validate, provider:, start_date: nil) }

    it "omits the start date line" do
      render_component

      expect(page).to have_no_css('span.govuk-\!-font-size-16')
    end
  end

  describe "course information field gating" do
    subject(:render_with) { render_inline(described_class.new(courses:, provider:, course_information_fields:)) }

    before do
      create(:course, :published_postgraduate, provider:, name: "Biology", course_code: "B123", start_date: Time.zone.local(2026, 9, 1))
    end

    context "when only one field is shown" do
      let(:course_information_fields) { [:funding] }

      it "renders only that field and marks the cell as sparse" do
        render_with

        within(".app-table--courses__course-information") do
          expect(page).to have_text("Fee-paying")
          expect(page).to have_no_text("QTS with PGCE")
          expect(page).to have_no_text("Full time")
        end
        expect(page).to have_css(".app-table--courses__course-information--sparse")
      end
    end

    context "when several fields are shown" do
      let(:course_information_fields) { %i[funding qualification study_mode] }

      it "does not mark the cell as sparse" do
        render_with

        expect(page).to have_no_css(".app-table--courses__course-information--sparse")
      end
    end

    context "when no fields are shown" do
      let(:course_information_fields) { [] }

      it "drops the Course information column entirely" do
        render_with

        expect(page.all(".govuk-table__header").map(&:text)).to eq(%w[Course Status])
        expect(page).to have_no_css(".app-table--courses__course-information")
      end
    end
  end
end
