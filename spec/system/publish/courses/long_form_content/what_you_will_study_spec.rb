# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a course with long form content", service: :publish do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    sign_in_system_test(user:)
  end

  scenario "A user CAN'T update the 'What you will study' page if theoretcial training activities section is blank" do
    FeatureFlag.activate(:long_form_content)

    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_what_you_will_study_fields(theoretical_training_activities: "", assessment_methods: "Some assessment methods")

    expect(page).to have_content("Enter details about theoretical training activities")
  end

  scenario "A user CANNOT update the 'What you will study' page if the theoretical training activities field and/or the assessment method field is over the word count" do
    FeatureFlag.activate(:long_form_content)

    given_there_is_a_draft_course
    when_i_visit_the_course_page
    then_i_edit_the_what_you_will_study_fields(theoretical_training_activities: generate_text(151), assessment_methods: generate_text(51))

    expect(page).to have_content("Reduce the word count for theoretical training activities")
    expect(page).to have_content("Reduce the word count for assessment methods")
  end

  scenario "A user CAN see the new 'What you will study' content fields if the current cycle in 2026 or beyond" do
    FeatureFlag.activate(:long_form_content)

    given_the_recruitment_cycle_year(2026)
    given_there_is_a_draft_course(recruitment_cycle: RecruitmentCycle.current)
    when_i_visit_the_course_page

    expect(page).to have_content("What you will study")

    and_change_link_has_correct_route
  end

  scenario "A user CANNOT see the new long form course content fields if the current cycle is before 2026" do
    given_the_recruitment_cycle_year(2025)
    given_there_is_a_draft_course(recruitment_cycle: RecruitmentCycle.current)
    when_i_visit_the_course_page

    expect(page).not_to have_content("What you will study")
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

  def when_i_visit_the_course_page
    visit publish_provider_recruitment_cycle_course_path(
      @course.provider.provider_code,
      @course.start_date.year,
      @course.course_code,
    )
    expect(page).to have_content(@course.name)
  end

  def then_i_edit_the_what_you_will_study_fields(theoretical_training_activities:, assessment_methods:)
    all("a", text: "Change")[7].click
    expect(page).to have_content("What you will study")

    fill_in "What will trainees do during their theoretical training?", with: theoretical_training_activities
    fill_in "How will they be assessed? (optional)", with: assessment_methods
    expect(page).to have_current_path(fields_what_you_will_study_publish_provider_recruitment_cycle_course_path(@course.provider.provider_code,
                                                                                                                @course.start_date.year,
                                                                                                                @course.course_code))
    click_button "Update what you will study"
  end

  def and_change_link_has_correct_route
    all("a", text: "Change")[7].click
    expect(page).to have_current_path(fields_what_you_will_study_publish_provider_recruitment_cycle_course_path(@course.provider.provider_code,
                                                                                                                @course.start_date.year,
                                                                                                                @course.course_code))
  end

  def given_the_recruitment_cycle_year(year)
    RecruitmentCycle.create!(
      year: year,
      application_start_date: Date.new(year - 1, 10, 9),
      application_end_date: Date.new(year, 9, 30),
      available_for_support_users_from: Date.new(year - 1, 10, 9),
      available_in_publish_from: Date.new(year - 1, 10, 9),
    )
  end

  def generate_text(word_count)
    Faker::Lorem.words(number: word_count).join(" ")
  end
end
