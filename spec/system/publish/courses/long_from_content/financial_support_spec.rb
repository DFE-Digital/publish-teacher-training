# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a course with long form content", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    sign_in_system_test(user:)
  end

  scenario "A user CANT update fees and financial support page if fees are blank" do
    FeatureFlag.activate(:long_form_content)

    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_fees_and_financial_support_fields(uk_fee: nil, international_fee: nil)

    expect(page).to have_content("Enter fee for UK citizens")
    expect(page).to have_content("Enter fee for non-UK citizens")
  end

  scenario "A user CANT update fees and financial support page if fees above or equal to 100_000" do
    FeatureFlag.activate(:long_form_content)

    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_fees_and_financial_support_fields(uk_fee: 200_000, international_fee: 200_000)

    expect(page).to have_content("Course fee for UK citizens must be less than or equal to £100,000")
    expect(page).to have_content("Course fee for non-UK citizens must be less than or equal to £100,000")
  end

  scenario "A user CANT update fees and financial support page if optional fields are above the word count" do
    FeatureFlag.activate(:long_form_content)

    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_fees_and_financial_support_fields(
      fee_schedule: generate_text(51),
      additional_fees: generate_text(51),
      financial_support: generate_text(251),
    )

    expect(page).to have_content("Reduce the word count for fee schedule")
    expect(page).to have_content("Reduce the word count for additional fees")
    expect(page).to have_content("Reduce the word count for financial support")
  end

  scenario "A user CAN see the new long form course content fields if the current cycle is 2026 or beyond" do
    FeatureFlag.activate(:long_form_content)

    current_recruitment_cycle = RecruitmentCycle.create!(
      year: 2026,
      application_start_date: Date.new(2025, 10, 9),
      application_end_date: Date.new(2026, 9, 30),
      available_for_support_users_from: Date.new(2025, 10, 9),
      available_in_publish_from: Date.new(2025, 10, 9),
    )

    given_there_is_a_draft_course(recruitment_cycle: current_recruitment_cycle)
    when_i_visit_the_course_page

    expect(page).to have_content("Fee for UK citizens")
    expect(page).to have_content("Fee for international citizens")
    expect(page).to have_content("Fees and financial support")

    then_change_links_use_new_routes
  end

  scenario "A user CANT see the new long form course content fields if the current cycle is before 2026" do
    current_recruitment_cycle = RecruitmentCycle.create!(
      year: 2024,
      application_start_date: Date.new(2023, 10, 9),
      application_end_date: Date.new(2024, 9, 30),
      available_for_support_users_from: Date.new(2023, 10, 9),
      available_in_publish_from: Date.new(2023, 10, 9),
    )

    given_there_is_a_draft_course(recruitment_cycle: current_recruitment_cycle)
    when_i_visit_the_course_page

    expect(page).to have_content("Fee for UK students")
    expect(page).to have_content("Fee for international students")
    expect(page).to have_content("Fees and financial support (optional)")

    then_change_links_use_old_routes
  end

  def when_i_visit_the_course_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}"
    expect(page).to have_content(@course.name)
  end

  def then_i_edit_the_fees_and_financial_support_fields(
    uk_fee: 2000,
    international_fee: 2000,
    fee_schedule: "Paragraph 1",
    additional_fees: "Paragraph 2",
    financial_support: "Paragraph 3"
  )
    all("a", text: "Change")[3].click
    expect(page).to have_content("Fees and financial support")

    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support")

    fill_in "Fee for UK citizens", with: uk_fee
    fill_in "Fee for non-UK citizens", with: international_fee

    fill_in "When are the fees due? Is there a payment schedule? (optional)", with: fee_schedule
    fill_in "Are there any additional fees or costs? (optional)", with: additional_fees
    fill_in "Does your organisation offer any financial support? (optional)", with: financial_support

    click_link_or_button "Update fees and financial support"
  end

  def given_there_is_a_draft_course(recruitment_cycle: RecruitmentCycle.current)
    provider_in_cycle = create(:provider, recruitment_cycle: recruitment_cycle)
    user.providers << provider_in_cycle

    course_enrichment = build(:course_enrichment, :initial_draft, course_length: :TwoYears)

    @course = create(
      :course,
      :with_accrediting_provider,
      :with_gcse_equivalency,
      :can_sponsor_student_visa,
      provider: provider_in_cycle,
      accrediting_provider: build(:accredited_provider),
      enrichments: [course_enrichment],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
      applications_open_from: recruitment_cycle.application_start_date + 1.day,
      start_date: Date.new(recruitment_cycle.year.to_i, 9, 1),
    )
  end

  def then_change_links_use_old_routes
    all("a", text: "Change")[6].click
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fees-and-financial-support")
  end

  def then_change_links_use_new_routes
    all("a", text: "Change")[3].click
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support")
  end

  def generate_text(word_count)
    "#{Faker::Lorem.words(number: word_count).join(' ').capitalize}."
  end
end
