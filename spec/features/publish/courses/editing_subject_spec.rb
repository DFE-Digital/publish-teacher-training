# frozen_string_literal: true

require 'rails_helper'

feature 'updating a subject', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'updating primary subject' do
    and_there_is_a_primary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_primary_subject('Primary with English')
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message
  end

  scenario 'updating secondary subject' do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:business_studies)
    and_i_click_continue
    then_i_am_met_with_course_details_page
    and_i_should_see_a_success_message
  end

  scenario 'updating secondary subject modern languages' do
    and_there_is_a_secondary_course_i_want_to_edit
    when_i_visit_the_edit_course_subject_page
    when_i_select_a_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  private

  def and_i_should_see_a_success_message
    expect(page).to have_content(I18n.t('success.saved', value: 'Subject'))
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_there_is_a_secondary_course_i_want_to_edit
    given_a_course_exists(:secondary)
  end

  def and_there_is_a_primary_course_i_want_to_edit
    given_a_course_exists(:primary)
  end

  def when_i_visit_the_edit_course_subject_page
    publish_courses_subjects_edit_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, course_code: course.course_code)
  end

  def when_i_select_a_primary_subject(subject_type)
    publish_courses_new_subjects_page.choose(subject_type)
  end

  def when_i_select_a_subject(subject_type)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_click_continue
    publish_courses_new_subjects_page.continue.click
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

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/modern-languages?#{params_with_subject}")
    expect(page).to have_content('Languages')
  end

  def course_subject(subject_type)
    case subject_type
    when :primary_with_english
      find_or_create(:primary_subject, :primary_with_english)
    when :business_studies
      find_or_create(:secondary_subject, :business_studies)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    end
  end

  def params_with_subject
    course_subject = course_subject(:modern_languages)
    "course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end
end
