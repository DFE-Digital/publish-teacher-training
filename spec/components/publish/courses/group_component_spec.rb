# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::GroupComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(group:, provider:)) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, :published_postgraduate, provider:) }

  context "with a headed (ratified) group" do
    let(:accredited_provider) { create(:accredited_provider, provider_name: "Heading University") }
    let(:group) do
      ProviderCoursesQuery::Group.new(accredited_provider:, courses: [course.decorate])
    end

    it "renders the accredited provider heading and caption" do
      render_component

      expect(page).to have_css("h2", text: "Heading University")
      expect(page).to have_css(".govuk-caption-m", text: "Accredited provider")
    end

    it "renders the courses table inside a tagged section" do
      render_component

      expect(page).to have_css('section[data-qa="courses__table-section"] table.app-table--courses')
      expect(page).to have_text(course.name_and_code)
    end
  end

  context "with a self-accredited group" do
    let(:group) do
      ProviderCoursesQuery::Group.new(accredited_provider: nil, courses: [course.decorate])
    end

    it "does not render a heading" do
      render_component

      expect(page).to have_no_css("h2")
    end

    it "still renders the courses table" do
      render_component

      expect(page).to have_css('section[data-qa="courses__table-section"] table.app-table--courses')
      expect(page).to have_text(course.name_and_code)
    end
  end
end
