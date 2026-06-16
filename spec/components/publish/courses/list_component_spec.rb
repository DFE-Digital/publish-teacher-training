# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::ListComponent, type: :component do
  subject(:render_component) do
    render_inline(described_class.new(course_list: Publish::CourseList.new(provider: provider.reload), provider:))
  end

  context "when the provider has self-accredited and ratified courses" do
    let(:provider) { create(:provider, :accredited_provider, provider_name: "Mid Provider") }

    before do
      create(:course, :published_postgraduate, provider:)
      create(:course, :published_postgraduate, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Zoo College"))
      create(:course, :published_postgraduate, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Aardvark University"))
    end

    it "renders one section per group, self-accredited first then alphabetical" do
      render_component

      expect(page).to have_css("section.app-table--courses__section", count: 3)
      expect(page.all("h2").map { |h2| h2.text.squish }).to eq(
        ["Accredited provider Aardvark University", "Accredited provider Zoo College"],
      )
    end

    it "renders the self-accredited group first, without a heading, but with its table" do
      render_component

      first_section = page.all("section.app-table--courses__section").first
      expect(first_section).to have_no_css("h2")
      expect(first_section).to have_css("table.app-table--courses")
    end
  end

  context "course information column across the whole list" do
    let(:provider) { create(:provider, :accredited_provider) }

    it "hides the column when every course shares the same information" do
      create_list(:course, 2, :without_validation, provider:)
      render_component

      expect(page).to have_no_text("Course information")
    end

    it "shows the column when course information varies" do
      create(:course, :without_validation, provider:, study_mode: :full_time)
      create(:course, :without_validation, provider:, study_mode: :part_time)
      render_component

      expect(page).to have_text("Course information")
    end
  end

  context "when the provider has no courses" do
    let(:provider) { create(:provider) }

    it "renders nothing" do
      render_component

      expect(page).to have_no_css("section")
      expect(page).to have_no_css("table")
    end
  end
end
