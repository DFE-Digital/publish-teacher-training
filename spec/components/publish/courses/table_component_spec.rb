# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::TableComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(courses:, provider:)) }

  let(:provider) { create(:provider) }
  # Rows carry the read-model column (content_status), so source them through
  # the query exactly as the page does.
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

    it "renders the course name as a link and the age range hint" do
      render_component

      within(".app-table--courses__course-name") do
        expect(page).to have_link("Biology (B123)")
        expect(page).to have_css(".govuk-hint", text: "Ages 3 to 7")
      end
    end

    context "when the table's provider does not own the course" do
      subject(:render_component) { render_inline(described_class.new(courses:, provider: accredited_provider)) }

      let(:accredited_provider) { create(:provider, :accredited_provider) }

      it "renders the course name as text, not a link" do
        render_component

        within(".app-table--courses__course-name") do
          expect(page).to have_text("Biology (B123)")
          expect(page).to have_no_link("Biology (B123)")
        end
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

      it "renders only that field and marks the row as sparse" do
        render_with

        within(".app-table--courses__course-information") do
          expect(page).to have_text("Fee-paying")
          expect(page).to have_no_text("QTS with PGCE")
          expect(page).to have_no_text("Full time")
        end
        expect(page).to have_css(".app-table--courses__row--sparse")
      end
    end

    context "when several fields are shown" do
      let(:course_information_fields) { %i[funding qualification study_mode] }

      it "does not mark the row as sparse" do
        render_with

        expect(page).to have_no_css(".app-table--courses__row--sparse")
      end
    end

    context "when no fields are shown" do
      let(:course_information_fields) { [] }

      it "drops the Course information column and lays out for Course and Status only" do
        render_with

        expect(page.all(".govuk-table__header").map(&:text)).to eq(%w[Course Status])
        expect(page).to have_no_css(".app-table--courses__course-information")
        expect(page).to have_css("table.app-table--courses--no-information")
        expect(page).to have_css(".app-table--courses__row--sparse")
      end
    end
  end

  describe "the View course column" do
    subject(:render_with) { render_inline(described_class.new(courses:, provider:, view_course_column: true)) }

    it "is off by default, leaving the provider's own course list as it was" do
      create(:course, :published_postgraduate, provider:)
      render_component

      expect(page.all(".govuk-table__header").map(&:text)).not_to include("View course")
      expect(page).to have_no_css(".app-table--courses__view-course")
    end

    context "with a course that is live on Find" do
      before { create(:course, :published_postgraduate, provider:, name: "Biology", course_code: "B123") }

      it "heads the column and links to the course on Find" do
        render_with

        expect(page.all(".govuk-table__header").map(&:text)).to eq(["Course", "Course information", "Status", "View course"])
        expect(page).to have_css("table.app-table--courses--view-course")
        expect(page.find(".app-table--courses__view-course a")[:href])
          .to include("find.localhost/course/#{provider.provider_code}/B123")
      end

      it "names the course in the link, since every row would otherwise read alike" do
        render_with

        within(".app-table--courses__view-course") do
          expect(page).to have_css("a .govuk-visually-hidden", text: "for Biology (B123)")
        end
      end
    end

    context "with a mix of live and unpublished courses" do
      before do
        create(:course, :published_postgraduate, provider:, name: "Biology", course_code: "B123")
        create(
          :course, :with_full_time_sites, provider:, name: "Physics", course_code: "P456",
                                          enrichments: [build(:course_enrichment, :initial_draft, course: nil)]
        )
      end

      it "leaves the cell empty for the course with nowhere live to point at" do
        render_with

        cells = page.all(".app-table--courses__view-course").map { |cell| cell.text.strip }
        expect(cells).to contain_exactly(a_string_including("View live course"), "")
      end
    end

    context "when no course in the list is live on Find" do
      before do
        create(
          :course, :with_full_time_sites, provider:,
                                          enrichments: [build(:course_enrichment, :initial_draft, course: nil)]
        )
      end

      it "drops the column rather than heading a set of empty cells" do
        render_with

        expect(page.all(".govuk-table__header").map(&:text)).not_to include("View course")
        expect(page).to have_no_css(".app-table--courses__view-course")
      end
    end
  end
end
