# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Dynamic preview", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    FeatureFlag.activate(:long_form_content)
    sign_in_system_test(user:)
  end

  scenario "interview location preview shows one inset text for Online", :js do
    given_there_is_a_draft_course
    and_i_visit_the_interview_process_fields_page

    choose "Online"
    within("[data-preview-target='interview_location']") do
      expect(page).to have_css(".govuk-inset-text", text: "Online interviews are available for this course")
    end
  end

  scenario "interview location preview shows one inset text with hint for Either in person or online", :js do
    given_there_is_a_draft_course
    and_i_visit_the_interview_process_fields_page

    choose "Either in person or online"
    within("[data-preview-target='interview_location']") do
      expect(page).to have_css(".govuk-inset-text", text: "Online interviews are available for this course")
      expect(page).to have_css(".govuk-inset-text .govuk-hint", text: "Depending on individual circumstances")
    end
  end

  scenario "fees preview renders pound sign for UK and non-UK citizens", :js do
    given_there_is_a_draft_course
    when_i_visit_the_fees_fields_page

    fill_in "Fee for UK citizens", with: "1234"
    within("[data-preview-target='currency1']") do
      expect(page).to have_text("£1234")
    end

    fill_in "Fee for non-UK citizens", with: "1234"
    within("[data-preview-target='currency2']") do
      expect(page).to have_text("£1234")
    end
  end

  scenario "generic preview shows typed content", :js do
    given_there_is_a_draft_course
    and_i_visit_the_interview_process_fields_page

    fill_in "What is the interview process? (optional)", with: "Hello world"
    within("[data-preview-target='shared']") do
      expect(page).to have_text("Hello world")
    end
  end

private

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

  def when_i_visit_the_course_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.start_date.year}/courses/#{@course.course_code}"
    expect(page).to have_content(@course.name)
  end

  def and_i_visit_the_interview_process_fields_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/interview-process"
    expect(page).to have_content("What is the interview process? (optional)")
  end

  def when_i_visit_the_fees_fields_page
    visit "/publish/organisations/#{@course.provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/fields/fees-and-financial-support"
    expect(page).to have_content("Fees and financial support")
  end
end
