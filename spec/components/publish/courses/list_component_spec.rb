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

      expect(page).to have_css('section[data-qa="courses__table-section"]', count: 3)
      expect(page.all("h2").map { |h2| h2.text.squish }).to eq(
        ["Accredited provider Aardvark University", "Accredited provider Zoo College"],
      )
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
