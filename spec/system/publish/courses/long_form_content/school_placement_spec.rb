# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a course with long form content on the school placement route", service: :publish, type: "system" do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    sign_in_system_test(user:)
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(true)
  end

  scenario "A user gets redirected to the course page if the long form content feature flag is not active" do
    allow(FeatureFlag).to receive(:active?).with(:long_form_content).and_return(false)
    allow(FeatureFlag).to receive(:active?).with(:bursaries_and_scholarships_announced).and_return(true)
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @course.provider.provider_code,
        @course.start_date.year,
        @course.course_code,
      ),
    )
  end

  scenario "A user visits the course page and clicks on the school placement link" do
    given_there_is_a_draft_course
    when_i_visit_the_course_page
    expect(page).to have_content("What you will do on school placements")
    expect(page).to have_link("Change what you will do on school placements")
    click_link "Change what you will do on school placements"
    expect(page).to have_current_path(
      fields_school_placement_publish_provider_recruitment_cycle_course_path(
        @course.provider.provider_code,
        @course.start_date.year,
        @course.course_code,
      ),
    )
    expect(page).to have_content("What you will do on school placements")
  end

  scenario "A user CANT update the Enrichment if What will trainees do while in their placement schools is blank" do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: "", support_and_mentorship: "")
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("Enter what will trainees do while in their placement schools")
  end

  scenario "A user CANT update the Enrichment if they only have supported and mentored filled out" do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: "", support_and_mentorship: "Some support")
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("Enter what will trainees do while in their placement schools")
  end

  scenario "A user CANT update the Enrichment if What will trainees do while in their placement schools has over 150 words" do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: generate_text(151), support_and_mentorship: "")
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("'What will trainees do while in their placement schools?' must be 150 words or less")
  end

  scenario "A user CANT update the Enrichment if How will they be supported and mentored is over 50 words" do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: "ABC", support_and_mentorship: generate_text(51))
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("'How will they be supported and mentored?' must be 50 words or less")
  end

  scenario "A user can see his past cycles fields", :js do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_should_not_see_the_fields_from_the_last_cycle
    then_i_should_see_a_collapsible_section_for_the_last_cycle_content
    then_i_should_see_the_fields_from_the_last_cycle
  end

  scenario "A user only updates the school placement activity field", :js do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: "New activities", support_and_mentorship: "")
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("What you will do on school placements")
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @course.provider.provider_code,
        @course.start_date.year,
        @course.course_code,
      ),
    )
    expect(CourseEnrichment.last.placement_school_activities).to eq("New activities")
    expect(CourseEnrichment.last.support_and_mentorship).to eq("")
  end

  scenario "A user can update the school placement activity field and support field", :js do
    given_there_is_a_draft_course
    when_i_visit_the_school_placement_page
    then_i_edit_the_school_placement_fields(placement_school_activities: "New activities", support_and_mentorship: "New support")
    click_link_or_button "Update what you will do on school placements"
    expect(page).to have_content("What you will do on school placements")
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @course.provider.provider_code,
        @course.start_date.year,
        @course.course_code,
      ),
    )
    expect(CourseEnrichment.last.placement_school_activities).to eq("New activities")
    expect(CourseEnrichment.last.support_and_mentorship).to eq("New support")
  end

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
    expect(page).to have_content("What you will do on school placements") if FeatureFlag.active?(:long_form_content)
  end

  def then_i_should_see_something_in_the_preview(text)
    expect(page).to have_css("p[data-preview-target='shared']", text: text)
  end

  def then_i_edit_the_school_placement_fields(placement_school_activities: nil, support_and_mentorship: nil)
    fill_in "What will trainees do while in their placement schools?", with: placement_school_activities
    fill_in "How will they be supported and mentored? (optional)", with: support_and_mentorship
  end

  def given_there_is_a_draft_course(recruitment_cycle: RecruitmentCycle.current)
    provider_in_cycle = create(:provider, recruitment_cycle: recruitment_cycle)
    user.providers << provider_in_cycle

    @course_enrichment ||= build(:course_enrichment, :v1, :initial_draft, course_length: :TwoYears, placement_school_activities: nil, support_and_mentorship: nil)

    @course = create(
      :course,
      :with_accrediting_provider,
      :with_gcse_equivalency,
      :can_sponsor_student_visa,
      provider: provider_in_cycle,
      accrediting_provider: build(:accredited_provider),
      enrichments: [@course_enrichment],
      sites: [create(:site, location_name: "location 1")],
      study_sites: [create(:site, :study_site)],
      applications_open_from: recruitment_cycle.application_start_date + 1.day,
      start_date: Date.new(recruitment_cycle.year.to_i, 9, 1),
    )
  end

  def then_i_should_not_see_the_fields_from_the_last_cycle
    expect(page).not_to have_content("About this course")
    expect(page).not_to have_content(@course_enrichment.about_course)
    expect(page).not_to have_content("How placements work")
    expect(page).not_to have_content(@course_enrichment.how_school_placements_work)
  end

  def then_i_should_see_a_collapsible_section_for_the_last_cycle_content
    expect(page).to have_content("See what you wrote last cycle")
    page.find("span", text: "See what you wrote last cycle").click
  end

  def then_i_should_see_the_fields_from_the_last_cycle
    expect(page).to have_content("About this course")
    expect(page).to have_content(@course_enrichment.about_course)
    expect(page).to have_content("How placements work")
    expect(page).to have_content(@course_enrichment.how_school_placements_work)
  end

  def generate_text(word_count)
    "#{Faker::Lorem.words(number: word_count).join(' ').capitalize}."
  end
end
