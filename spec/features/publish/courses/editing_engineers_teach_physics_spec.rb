# frozen_string_literal: true

require "rails_helper"

feature "updating engineers teach physics" do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "updating subject to physics" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_publish_courses_edit_engineers_teach_physics_page
    and_i_click_continue
    then_i_see_an_error_message
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message("Engineers Teach Physics")
  end

  scenario "back links return to correct pages" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_select_subordinate_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_edit_engineers_teach_physics_with_languages_page
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_edit_modern_languages_page
    when_i_go_back
    then_i_return_to_the_edit_engineers_teach_physics_with_languages_page
    when_i_go_back
    then_i_return_to_the_edit_course_subject_page
  end

  scenario "updating subject to physics with modern languages" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_select_subordinate_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_edit_engineers_teach_physics_with_languages_page
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_edit_modern_languages_page
    and_i_select_a_language
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message("Subjects")
  end

  scenario "updating subject from physics to another subject resets campaign_name" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_publish_courses_edit_engineers_teach_physics_page
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_course_details_page
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:latin)
    and_i_click_continue
    then_i_am_met_with_course_details_page
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_publish_courses_edit_engineers_teach_physics_page
    and_i_click_continue
    then_i_see_an_error_message
  end

private

  def then_i_see_an_error_message
    expect(page).to have_content("Select if this course is part of the Engineers teach physics programme")
  end

  def and_i_select_an_option
    publish_courses_new_engineers_teach_physics_page.campaign_fields.engineers_teach_physics.click
  end

  def and_i_select_subordinate_subject(subject_type)
    publish_courses_subjects_edit_page.subordinate_subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_should_see_a_success_message(value)
    expect(page).to have_content(I18n.t("success.saved", value:))
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_there_is_a_secondary_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def when_i_visit_the_edit_course_subject_page
    publish_courses_subjects_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, course_code: course.course_code)
  end

  def when_i_select_a_subject(subject_type)
    publish_courses_subjects_edit_page.master_subject_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_click_continue
    publish_courses_subjects_edit_page.continue.click
  end

  def when_i_go_back
    click_link_or_button("Back")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def course
    @course ||= provider.courses.first
  end

  def then_i_am_met_with_course_details_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/details")
  end

  def then_i_return_to_the_edit_course_subject_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/subjects")
  end

  def then_i_return_to_the_edit_engineers_teach_physics_with_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/engineers_teach_physics?#{course_subject_ids}")
  end

  def then_i_am_met_with_the_publish_courses_edit_engineers_teach_physics_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/engineers_teach_physics?#{params_with_subject}")
    expect(page).to have_content("Engineers Teach Physics")
  end

  def then_i_am_met_with_the_edit_engineers_teach_physics_with_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/engineers_teach_physics?#{modern_languages_with_form_params}")
    expect(page).to have_content("Engineers Teach Physics")
  end

  def then_i_am_met_with_the_edit_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/modern-languages?#{modern_languages_subject_ids}")
    expect(page).to have_content("Languages")
  end

  def and_i_select_a_language
    publish_courses_new_modern_languages_page.language_checkbox("German").click
  end

  def course_subject(subject_type)
    case subject_type
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :latin
      find_or_create(:secondary_subject, :latin)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    end
  end

  def params_with_subject
    course_subject = course_subject(:physics)
    "course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end

  def modern_languages_with_form_params
    subordinate_subject = course_subject(:modern_languages)
    course_subject = course_subject(:physics)
    "course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}"
  end

  def course_subject_ids
    master_subject = course_subject(:physics)
    "course%5Bmaster_subject_id%5D=#{master_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course.subject_ids.first}"
  end

  def modern_languages_subject_ids
    subordinate_subject = course_subject(:modern_languages)
    course_subject = course_subject(:physics)
    "course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}"
  end
end
