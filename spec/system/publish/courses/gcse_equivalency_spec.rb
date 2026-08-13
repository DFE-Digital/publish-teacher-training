# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GCSE equivalency requirements" do
  scenario "a provider completes the gcse equivalency requirements section" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_publish_courses_gcse_requirements_page(course:)

    and_i_click_save
    and_i_see_pending_gcse_and_equivalency_tests_errors
    and_i_set_the_gcse_requirements

    and_there_is_no_science_equivalency
    and_i_click_save
    and_i_see_equivalency_errors

    and_i_set_the_gcse_requirements
    then_i_see_markdown_formatting_guidance

    when_i_fill_the_equivalency_requirements
    and_i_click_save

    then_i_am_on_the_course_page
    and_i_see_the_success_summary
  end

  scenario "a provider views course pages with course 2 GCSE requirements" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_page(course: course2)

    then_i_see_course_2_gcse_requirements
  end

  scenario "a provider views course pages with course 3 GCSE requirements" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_page(course: course3)

    then_i_see_course_3_gcse_requirements(grade: 4)
  end

  scenario "a provider with Grade 5 GCSE requirements" do
    given_i_am_authenticated(user: user_with_courses(:gcse_grade_5))
    when_i_visit_the_course_page(course: course3)

    then_i_see_course_3_gcse_requirements(grade: 5)
  end

  scenario "a provider has completed the pending GCSE & equivalency requirements and sees their answer pre-populated on the gcse requirements page" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_publish_courses_gcse_requirements_page(course: course3)

    then_i_see_the_form_pre_populated
  end

  scenario "a provider copies gcse data from another course with all fields" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_publish_courses_gcse_requirements_page(course:)
    and_i_copy_the_content_from(course3)

    then_i_see_the_copied_fields_warning
    and_i_see_the_form_pre_populated
  end

  scenario "a provider copies gcse data from another course with missing fields" do
    given_i_am_authenticated(user: user_with_courses)
    when_i_visit_the_course_publish_courses_gcse_requirements_page(course:)
    and_i_copy_the_content_from(course2)

    then_i_do_not_see_the_copied_fields_warning
    and_i_see_the_form_is_empty
  end

private

  def user_with_courses(*provider_traits)
    provider = build(:provider, *provider_traits, courses: gcse_courses)

    create(:user, providers: [provider])
  end

  def gcse_courses
    [
      build(:course, :secondary, course_code: "XXX1", additional_gcse_equivalencies: ""),
      build(:course, :primary, course_code: "XXX2", accept_pending_gcse: false, accept_gcse_equivalency: false, additional_gcse_equivalencies: nil),
      build(:course, :secondary,
            course_code: "XXX3", accept_pending_gcse: true, accept_gcse_equivalency: true,
            accept_english_gcse_equivalency: true, accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: nil,
            additional_gcse_equivalencies: "Cycling Proficiency"),
    ]
  end

  def provider
    @provider ||= @current_user.providers.first
  end

  def course
    @course ||= provider.courses.find_by(course_code: "XXX1")
  end

  def course2
    @course2 ||= provider.courses.find_by(course_code: "XXX2")
  end

  def course3
    @course3 ||= provider.courses.find_by(course_code: "XXX3")
  end

  def gcse_requirements_page
    publish_courses_gcse_requirements_page
  end

  def when_i_visit_the_course_publish_courses_gcse_requirements_page(course:)
    gcse_requirements_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_page(course:)
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def then_i_see_course_2_gcse_requirements
    expect(page).to have_content("Grade 4 (C) or above in English, maths and science")
    expect(page).to have_content("Candidates with pending GCSEs will not be considered")
    expect(page).to have_content("Equivalency tests will not be accepted")
  end

  def then_i_see_course_3_gcse_requirements(grade:)
    expect(page).to have_content("Grade #{grade} (C) or above in English and maths")
    expect(page).to have_content("Candidates with pending GCSEs will be considered")
    expect(page).to have_content("Equivalency tests will be accepted in English or maths")
    expect(page).to have_content("Cycling Proficiency")
  end

  def then_i_see_the_form_pre_populated
    expect(gcse_requirements_page.pending_gcse_yes_radio).to be_checked
    expect(gcse_requirements_page.gcse_equivalency_yes_radio).to be_checked
    expect(gcse_requirements_page.english_equivalency).to be_checked
    expect(gcse_requirements_page.maths_equivalency).to be_checked
    expect(gcse_requirements_page.additional_requirements.value).to eq("Cycling Proficiency")
  end
  alias_method :and_i_see_the_form_pre_populated, :then_i_see_the_form_pre_populated

  def and_i_see_the_form_is_empty
    expect(gcse_requirements_page.pending_gcse_no_radio).to be_checked
    expect(gcse_requirements_page.gcse_equivalency_no_radio).to be_checked
    expect(gcse_requirements_page.english_equivalency).not_to be_checked
    expect(gcse_requirements_page.maths_equivalency).not_to be_checked
    expect(gcse_requirements_page.additional_requirements.value).to eq("")
  end

  def and_i_copy_the_content_from(course)
    gcse_requirements_page.copy_content.copy(course)
  end

  def then_i_see_the_copied_fields_warning
    warning = gcse_requirements_page.copy_content_warning

    expect(warning).to have_content("Your changes are not yet saved")
    expect(warning).to have_content("Accept pending GCSE")
    expect(warning).to have_content("Accept GCSE equivalency")
    expect(warning).to have_content("Accept English GCSE equivalency")
    expect(warning).to have_content("Accept Maths GCSE equivalency")
    expect(warning).to have_content("Additional GCSE equivalencies")
  end

  def then_i_do_not_see_the_copied_fields_warning
    expect(gcse_requirements_page).not_to have_copy_content_warning
  end

  def and_i_click_save
    gcse_requirements_page.save.click
  end

  def and_i_see_pending_gcse_and_equivalency_tests_errors
    expect(page).to have_content("Select if you consider candidates with pending GCSEs")
    expect(page).to have_content("Select if you consider candidates with pending equivalency tests")
  end

  def and_i_set_the_gcse_requirements
    gcse_requirements_page.pending_gcse_yes_radio.click
    gcse_requirements_page.gcse_equivalency_yes_radio.click
  end

  def and_there_is_no_science_equivalency
    expect(gcse_requirements_page).not_to have_science_equivalency
  end

  def and_i_see_equivalency_errors
    expect(page).to have_content("Enter details about equivalency tests")
    expect(page).to have_content("Select if you accept equivalency tests in English or maths")
  end

  def then_i_see_markdown_formatting_guidance
    page.find("span", text: "How to create links and bullet points")
    expect(page).to have_content "How to create a link"
    expect(page).to have_content "How to create bullet points"
  end

  def when_i_fill_the_equivalency_requirements
    gcse_requirements_page.english_equivalency.check
    gcse_requirements_page.maths_equivalency.check
    gcse_requirements_page.additional_requirements.set("Cycling Proficiency")
  end

  def then_i_am_on_the_course_page
    expect(page).to have_current_path publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  def and_i_see_the_success_summary
    expect(publish_provider_courses_index_page.success_summary).to have_content("GCSE requirements updated")
  end
end
