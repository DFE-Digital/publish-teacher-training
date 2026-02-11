# frozen_string_literal: true

require "rails_helper"

RSpec.describe SavedCourses::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:summary_card_content) do
    rendered.text.squish
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

  it "renders a note row with an add-note link" do
    expect(summary_card_content).to include("Note")
    expect(rendered).to have_link("Add a note", href: edit_find_candidate_saved_course_note_path(saved_course))
  end

  it "does not render note actions when there is no note" do
    expect(rendered).not_to have_css(".govuk-summary-list__actions", text: /Edit|Delete/)
  end

  context "when a note has been added" do
    let(:saved_course) do
      create(
        :saved_course,
        candidate:,
        course:,
        note: "My note text",
      )
    end

    it "renders the note and edit/delete actions" do
      expect(summary_card_content).to include("Note")
      expect(summary_card_content).to include("My note text")
      within ".govuk-summary-list__actions" do
        expect(rendered).to have_link("Edit", href: edit_find_candidate_saved_course_note_path(saved_course))
        expect(rendered).to have_button("Delete")
        expect(rendered).to have_css("form[action='#{find_candidate_saved_course_note_path(saved_course)}']")
      end
    end

    it "renders the note value with 16px styling" do
      expect(rendered).to have_css("[class~='govuk-!-font-size-16']", text: "My note text")
    end

    it "renders delete note as a real DELETE form (not a link)" do
      form = rendered.css("form[action='#{find_candidate_saved_course_note_path(saved_course)}']").first
      expect(form).to be_present
      expect(form.css("input[name='_method'][value='delete']")).to be_present
    end
  end
end
