# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Incomplete fields on a course", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before { sign_in_system_test(user:) }

  scenario "every empty field on a fee paying course description prompts the user to fill it in" do
    given_there_is_a_draft_course_with_nothing_entered(funding: "fee")
    when_i_visit_the_course_page

    then_i_see_the_prompt("Enter course length", "/length")
    and_i_see_the_prompt("Enter fee for UK citizens", "/fields/fees-and-financial-support")
    and_i_see_the_prompt("Enter fee for non-UK citizens (optional)", "/fields/fees-and-financial-support")
    and_i_see_the_prompt("Enter fees and financial support (optional)", "/fields/fees-and-financial-support")
    and_i_see_the_prompt("Enter where trainees will train", "/fields/where-you-will-train")
    and_i_see_the_prompt("Enter what trainees will do on school placements", "/fields/school-placement")
    and_i_see_the_prompt("Enter what trainees will study", "/fields/what-you-will-study")
    and_i_see_the_prompt("Enter where the interviews will take place (optional)", "/fields/interview-process")
    and_i_see_the_prompt("Enter the interview process (optional)", "/fields/interview-process")

    and_the_key_reads("Fees and financial support (optional)")
    and_no_field_says_it_is_empty
  end

  scenario "every empty field on a salaried course description prompts the user to fill it in" do
    given_there_is_a_draft_course_with_nothing_entered(funding: "salary")
    when_i_visit_the_course_page

    then_i_see_the_prompt("Enter course length", "/length")
    and_i_see_the_prompt("Enter fees (optional)", "/salary-fees")
    and_i_see_the_prompt("Enter school experience (optional)", "/school-experience/experience-required")
    and_i_see_the_prompt("Enter what trainees will study", "/fields/what-you-will-study")

    and_the_key_reads("Fees (optional)")
    and_the_key_reads("School experience (optional)")
    and_no_field_says_it_is_empty
  end

  def given_there_is_a_draft_course_with_nothing_entered(funding:)
    recruitment_cycle = find_or_create(:recruitment_cycle, year: RecruitmentCycle.current.year.to_i + 1)
    provider = create(:provider, recruitment_cycle:)
    user.providers << provider

    @course = create(
      :course,
      funding:,
      provider:,
      enrichments: [build(:course_enrichment, :without_content, :initial_draft, financial_support: nil)],
      sites: [create(:site)],
      applications_open_from: recruitment_cycle.application_start_date + 1.day,
      start_date: Date.new(recruitment_cycle.year.to_i, 9, 1),
    )
  end

  def when_i_visit_the_course_page
    visit publish_provider_recruitment_cycle_course_path(@course.provider.provider_code, @course.recruitment_cycle_year, @course.course_code)
  end

  def then_i_see_the_prompt(text, path_fragment)
    link = page.find(".app-inset-text--important a", text:, exact_text: true)

    expect(link[:href]).to include(path_fragment)
  end
  alias_method :and_i_see_the_prompt, :then_i_see_the_prompt

  def and_the_key_reads(text)
    expect(page).to have_css(".govuk-summary-list__key", text:, exact_text: true)
  end

  def and_no_field_says_it_is_empty
    expect(page).to have_no_text("Not entered")
    expect(page).to have_no_text("Empty")
  end
end
