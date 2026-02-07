# frozen_string_literal: true

require "rails_helper"

RSpec.describe SavedCourses::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:summary_card_content) do
    rendered.text.gsub(/\r?\n/, " ").squeeze(" ").strip
  end

  let(:rendered) { render_inline(described_class.new(saved_course:)) }

  let(:saved_course) do
    create(
      :saved_course,
      candidate:,
      course:,
    )
  end

  let(:candidate) { create(:candidate) }

  let(:subject_with_incentives) do
    create(:secondary_subject, :physics, bursary_amount: 20_000, scholarship: 22_000)
  end

  let(:course) do
    create(
      :course,
      :secondary,
      :open,
      name: "Physics",
      course_code: "S252",
      provider: build(:provider, provider_name: "Best Practice Network", provider_code: "RO1"),
      subjects: [subject_with_incentives],
      master_subject_id: subject_with_incentives.id,
      enrichments: [create(:course_enrichment, :published, fee_uk_eu: 9535, fee_international: 17_500)],
    )
  end

  before do
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  it "renders a link to the course in Find" do
    expect(rendered).to have_link(
      "Best Practice Network",
      href: find_course_path(provider_code: "RO1", course_code: "S252"),
    )
  end

  it "renders a delete button that submits to the destroy route" do
    expect(rendered).to have_button("Delete")
    expect(rendered).to have_css("form[action='#{find_candidate_saved_course_path(saved_course)}']")
  end

  it "renders fee and bursary content" do
    expect(summary_card_content).to include("Fee or salary")
    expect(summary_card_content).to include("£9,535 fee for UK citizens")
    expect(summary_card_content).to include("£17,500 fee for Non-UK citizens")
    expect(summary_card_content).to include("Scholarships of £22,000 or bursaries of £20,000 are available")
  end
end
