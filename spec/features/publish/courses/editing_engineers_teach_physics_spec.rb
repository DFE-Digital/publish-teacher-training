# frozen_string_literal: true

require "rails_helper"

feature "updating engineers teach physics", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "updating subject to physics" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_edit_engineers_teach_physics_page
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_course_details_page
    # TODO: success message?
  end

  scenario "updating subject to physics with modern languages" do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:physics)
    and_i_open_second_subject
    and_i_select_subordinate_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_edit_engineers_teach_physics_with_languages_page
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_edit_modern_languages_page
    # TODO: success message?
  end

private

  def and_i_select_an_option
    new_engineers_teach_physics_page.campaign_fields.engineers_teach_physics.click
  end

  def and_i_open_second_subject
    subjects_edit_page.subordinate_subject_details.click
  end

  def and_i_select_subordinate_subject(subject_type)
    subjects_edit_page.subordinate_subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_should_see_a_success_message(value)
    expect(page).to have_content(I18n.t("success.value_saved", value:))
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_there_is_a_secondary_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def when_i_visit_the_edit_course_subject_page
    subjects_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, course_code: course.course_code)
  end

  def when_i_select_a_subject(subject_type)
    subjects_edit_page.subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_click_continue
    subjects_edit_page.continue.click
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

  def then_i_am_met_with_the_edit_engineers_teach_physics_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/engineers_teach_physics?#{params_with_subject}")
    expect(page).to have_content("Engineers Teach Physics")
  end

  def then_i_am_met_with_the_edit_engineers_teach_physics_with_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/engineers_teach_physics?#{modern_languages_with_form_params}")
    expect(page).to have_content("Engineers Teach Physics")
  end

  def then_i_am_met_with_the_edit_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/modern-languages?#{modern_languages_subject_ids}")
    expect(page).to have_content("Pick all the languages for this course")
  end

  def course_subject(subject_type)
    case subject_type
    when :physics
      find_or_create(:secondary_subject, :physics)
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

  def modern_languages_subject_ids
    subordinate_subject = course_subject(:modern_languages)
    course_subject = course_subject(:physics)
    "course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}"
  end
end

# /publish/organisations/A02/2023/courses/C251/engineers_teach_physics?course%5Bmaster_subject_id%5D=29&course%5Bsubjects_ids%5D%5B%5D=29&course%5Bsubjects_ids%5D%5B%5D=33

# /publish/organisations/A02/2023/courses/C251/modern-languages?course%5Bmaster_subject_id%5D=29&course%5Bsubjects_ids%5D%5B%5D=29

# /publish/organisations/A02/2023/courses/C276/engineers_teach_physics?course%5Bmaster_subject_id%5D=29&course%5Bsubjects_ids%5D%5B%5D=29&course%5Bsubjects_ids%5D%5B%5D=33

# publish/organisations/A02/2023/courses/C276/modern-languages?course%5Bmaster_subject_id%5D=29&course%5Bsubjects_ids%5D%5B%5D=29&course%5Bsubjects_ids%5D%5B%5D=33
