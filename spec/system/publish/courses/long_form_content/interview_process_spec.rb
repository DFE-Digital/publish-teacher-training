# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Editing a courses interview process with long form content", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    FeatureFlag.activate(:long_form_content)
    sign_in_system_test(user:)
  end

  scenario "A user CANT submit a courses interview process if its over 200 words" do
    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_interview_process_field(content: generate_text(201))

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Interview process must be 200 words or less")
  end

  scenario "A user CAN update a courses interview process and location" do
    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_interview_process_and_location_fields

    expect(page).to have_content("Interview process updated")
    expect(page).to have_content("Interview process content")
    expect(page).to have_content("Online")
  end

  scenario "A user can see last years interview process and location" do
    given_there_is_a_draft_course
    and_there_is_the_same_published_course_in_last_year

    when_i_visit_the_course_page
    and_i_click_to_change_the_interview_process_page

    expect(page).to have_content("Last years interview process")
    expect(page).to have_content("In person")
  end

  scenario "A user does NOT have a last years interview process and location" do
    given_there_is_a_draft_course
    when_i_visit_the_course_page
    and_i_click_to_change_the_interview_process_page
    expect(page).not_to have_content("See what you wrote last cycle")
    expect(page).not_to have_content("Last years interview process")
  end

  def when_i_visit_the_course_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}"
    expect(page).to have_content(@course.name)
  end

  def then_i_edit_the_interview_process_and_location_fields(content: "Interview process content")
    all("a", text: "Change").last.click
    expect(page).to have_content("What is the interview process? (optional)")

    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/interview-process")

    fill_in "What is the interview process? (optional)", with: content
    choose "Online"

    click_link_or_button "Update interview process"
  end

  def and_i_click_to_change_the_interview_process_page
    all("a", text: "Change").last.click
    expect(page).to have_content("What is the interview process? (optional)")
    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/interview-process")
  end

  def then_i_edit_the_interview_process_field(content: "Interview process content")
    all("a", text: "Change").last.click
    expect(page).to have_content("What is the interview process? (optional)")

    expect(page).to have_current_path("/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/interview-process")

    fill_in "What is the interview process? (optional)", with: content

    click_link_or_button "Update interview process"
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

  def and_there_is_the_same_published_course_in_last_year
    create(:recruitment_cycle, :previous) unless RecruitmentCycle.current.previous
    provider_in_last_cycle = create(:provider, provider_code: @course.provider.provider_code, recruitment_cycle: RecruitmentCycle.current.previous)
    user.providers << provider_in_last_cycle
    course_enrichment = build(:course_enrichment, :v1, :published, interview_process: "Last years interview process")
    @old_course = create(
      :course,
      :with_gcse_equivalency,
      :can_sponsor_student_visa,
      :without_validation,
      provider: provider_in_last_cycle,
      enrichments: [course_enrichment],
      course_code: @course.course_code,
    )
  end

  def generate_text(word_count)
    "#{Faker::Lorem.words(number: word_count).join(' ').capitalize}."
  end
end
