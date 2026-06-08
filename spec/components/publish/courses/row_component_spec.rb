# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::RowComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(course: row, provider:)) }

  let(:provider) { create(:provider) }
  # Rows carry the read-model columns (content_status, has_unpublished_changes), so
  # source them through the query exactly as the page does.
  let(:row) { Publish::Courses::Query.call(provider: provider.reload).find { |course| course.id == created_course.id }.decorate }

  context "with a published, open course" do
    let!(:created_course) { create(:course, :published_postgraduate, provider:, name: "Biology", course_code: "B123") }

    it "renders the course name and code" do
      render_component

      expect(page).to have_text("Biology (B123)")
    end

    it "renders the course information cell" do
      render_component

      expect(page).to have_css('[data-qa="courses-table__course-information"]', text: "QTS with PGCE")
    end

    it "renders the age range hint under the course name" do
      render_component

      expect(page).to have_css('[data-qa="courses-table__course-name"] .govuk-hint', text: "Ages 3 to 7")
    end

    it "renders the status tag" do
      render_component

      expect(page).to have_css('[data-qa="courses-table__status"] .govuk-tag', text: "Open")
    end
  end

  context "with a draft course" do
    let!(:created_course) { create(:course, :draft_enrichment, provider:) }

    it "renders the Draft status tag" do
      render_component

      expect(page).to have_css('[data-qa="courses-table__status"] .govuk-tag', text: "Draft")
    end
  end
end
