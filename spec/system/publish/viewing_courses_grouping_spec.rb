# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing the grouped course list" do
  let(:provider) { create(:provider, :accredited_provider, provider_name: "Mid Provider") }

  before do
    given_i_am_authenticated(user: create(:user, providers: [provider]))
  end

  scenario "courses are grouped by accredited provider, self-accredited first" do
    given_my_provider_has_self_accredited_and_ratified_courses
    when_i_visit_the_courses_page
    then_i_see_a_section_per_group
    and_the_self_accredited_section_has_no_heading
    and_the_ratified_sections_are_in_alphabetical_order
  end

  scenario "each course shows its status tag" do
    given_my_provider_has_courses_in_different_states
    when_i_visit_the_courses_page
    then_i_see_the_status_tag_for_each_course
  end

  scenario "a provider with no courses sees no course sections" do
    when_i_visit_the_courses_page
    then_i_see_no_course_sections
  end

  def given_my_provider_has_self_accredited_and_ratified_courses
    create(:course, provider:, accrediting_provider: nil)
    create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Zeta University"))
    create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Alpha University"))
  end

  def given_my_provider_has_courses_in_different_states
    create(:course, :published_postgraduate, provider:, name: "Open course")
    create(:course, :draft_enrichment, provider:, name: "Draft course")
    create(:course, :withdrawn, provider:, name: "Withdrawn course")
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_see_a_section_per_group
    expect(page).to have_css('[data-qa="courses__table-section"]', count: 3)
  end

  def and_the_self_accredited_section_has_no_heading
    # The self-accredited group is rendered first and has no <h2> heading.
    first_section = page.all('[data-qa="courses__table-section"]').first
    expect(first_section).to have_no_css("h2")
  end

  def and_the_ratified_sections_are_in_alphabetical_order
    headings = page.all('[data-qa="courses__table-section"] h2').map { |h2| h2.text.squish }
    expect(headings).to eq(
      ["Accredited provider Alpha University", "Accredited provider Zeta University"],
    )
  end

  def then_i_see_the_status_tag_for_each_course
    expect(page).to have_css(".govuk-tag", text: "Open")
    expect(page).to have_css(".govuk-tag", text: "Draft")
    expect(page).to have_css(".govuk-tag", text: "Withdrawn")
  end

  def then_i_see_no_course_sections
    expect(page).to have_css("h1", text: "Courses")
    expect(page).to have_no_css('[data-qa="courses__table-section"]')
  end
end
