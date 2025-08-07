# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a course with long form content on the school placement route", service: :publish, type: "system" do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    sign_in_system_test(user:)
  end

  # scenario "A user CANT update the Enrichment if What will trainees do while in their placement schools is blank" do
  #   allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)

  #   given_there_is_a_draft_course
  #   when_i_visit_the_course_page
  #   then_i_edit_the_fees_and_financial_support_fields(placement_school_activities: nil, support_and_mentorship: "ABC")

  #   expect(page).to have_content("Enter What will trainees do while in their placement schools?")
  # end

  # scenario "A user CANT update fees and financial support page if fees above or equal to 100_000" do
  #   allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)

  #   given_there_is_a_draft_course
  #   when_i_visit_the_course_page
  #   then_i_edit_the_fees_and_financial_support_fields(uk_fee: 200_000, international_fee: 200_000)

  #   expect(page).to have_content("Course fees for UK and EU students must be less than or equal to £100,000")
  #   expect(page).to have_content("Course fees for international students must be less than or equal to £100,000")
  # end

  # scenario "A user CANT update fees and financial support page if optional fields are above the word count" do
  #   allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)

  #   given_there_is_a_draft_course
  #   when_i_visit_the_course_page
  #   then_i_edit_the_fees_and_financial_support_fields(
  #     fee_schedule: generate_text(51),
  #     additional_fees: generate_text(51),
  #     financial_support: generate_text(251),
  #   )

  #   expect(page).to have_content("Reduce the word count for fee schedule")
  #   expect(page).to have_content("Reduce the word count for additional fees")
  #   expect(page).to have_content("Reduce the word count for financial support")
  # end

  # scenario "A user CAN see the new long form course content fields if the current cycle is 2026 or beyond" do
  #   allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)

  #   current_recruitment_cycle = RecruitmentCycle.create!(
  #     year: 2026,
  #     application_start_date: Date.new(2025, 10, 9),
  #     application_end_date: Date.new(2026, 9, 30),
  #     available_for_support_users_from: Date.new(2025, 10, 9),
  #     available_in_publish_from: Date.new(2025, 10, 9),
  #   )

  #   given_there_is_a_draft_course(recruitment_cycle: current_recruitment_cycle)
  #   when_i_visit_the_course_page

  #   expect(page).to have_content("Fee for UK students")
  #   expect(page).to have_content("Fee for international citizens")
  #   expect(page).to have_content("Fees and financial support")

  #   then_change_links_use_new_routes
  # end

  # scenario "A user CANT see the new long form course content fields if the current cycle is before 2026" do
  #   current_recruitment_cycle = RecruitmentCycle.create!(
  #     year: 2024,
  #     application_start_date: Date.new(2023, 10, 9),
  #     application_end_date: Date.new(2024, 9, 30),
  #     available_for_support_users_from: Date.new(2023, 10, 9),
  #     available_in_publish_from: Date.new(2023, 10, 9),
  #   )

  #   given_there_is_a_draft_course(recruitment_cycle: current_recruitment_cycle)
  #   when_i_visit_the_course_page

  #   expect(page).to have_content("Fee for UK students")
  #   expect(page).to have_content("Fee for international students")
  #   expect(page).to have_content("Fees and financial support (optional)")

  #   then_change_links_use_old_routes
  # end

  scenario "A user can see his changes in the dynamic preview when the field support_and_mentorship is changed", :js do
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_should_see_something_in_the_preview("The text you type above will show here.")
    then_i_edit_the_school_placement_fields(placement_school_activities: nil, support_and_mentorship: "ABC")
    then_i_should_see_something_in_the_preview("ABC")
  end

  scenario "A user can see his changes in the dynamic preview when the field placement_school_activities is changed", :js do
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_should_see_something_in_the_preview("The text you type above will show here.")
    then_i_edit_the_school_placement_fields(placement_school_activities: "ABC", support_and_mentorship: nil)
    then_i_should_see_something_in_the_preview("ABC")
  end

  scenario "A user can see his changes in the dynamic preview when the field placement_school_activities and support_and_mentorship is changed", :js do
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_should_see_something_in_the_preview("The text you type above will show here.")
    then_i_edit_the_school_placement_fields(placement_school_activities: "ABC", support_and_mentorship: "DEF")
    then_i_should_see_something_in_the_preview("ABC\nDEF")
  end

  scenario "A user can see his changes in the dynamic preview should return the default message if all text is deleted", :js do
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_should_see_something_in_the_preview("The text you type above will show here.")
    then_i_edit_the_school_placement_fields(placement_school_activities: "ABC", support_and_mentorship: "DEF")
    then_i_should_see_something_in_the_preview("ABC\nDEF")
    then_i_edit_the_school_placement_fields(placement_school_activities: "", support_and_mentorship: "")
    then_i_should_see_something_in_the_preview("The text you type above will show here.")
  end

  def when_i_visit_the_course_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}"
    expect(page).to have_content(@course.name)
  end

  def when_i_visit_the_school_placement_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}/fields/school-placement"
    expect(page).to have_content("What you will do on school placements")
  end

  def then_i_should_see_something_in_the_preview(text)
    expect(page).to have_css("p[data-preview-target='shared']", text: text)
  end

  def then_i_edit_the_school_placement_fields(placement_school_activities: nil, support_and_mentorship: nil)
    fill_in "What will trainees do while in their placement schools?", with: placement_school_activities
    fill_in "How will they be supported and mentored? (optional)", with: support_and_mentorship
  end

  # def then_i_edit_the_fees_and_financial_support_fields(
  #   uk_fee: 2000,
  #   international_fee: 2000,
  #   fee_schedule: "Paragraph 1",
  #   additional_fees: "Paragraph 2",
  #   financial_support: "Paragraph 3"
  # )
  #   all("a", text: "Change")[3].click
  #   expect(page).to have_content("Fees and financial support")

  #   expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support")

  #   fill_in "Fee for UK citizens", with: uk_fee
  #   fill_in "Fee for international students", with: international_fee

  #   fill_in "When are the fees due? Is there a payment schedule? (optional)", with: fee_schedule
  #   fill_in "Are there any additional fees or costs? (optional)", with: additional_fees
  #   fill_in "Does your organisation offer any financial support? (optional)", with: financial_support

  #   click_link_or_button "Update fees and financial support"
  # end

  def given_there_is_a_draft_course(recruitment_cycle: RecruitmentCycle.current)
    provider_in_cycle = create(:provider, recruitment_cycle: recruitment_cycle)
    user.providers << provider_in_cycle

    course_enrichment = build(:course_enrichment, :v2, :initial_draft, course_length: :TwoYears, placement_school_activities: nil, support_and_mentorship: nil)

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
