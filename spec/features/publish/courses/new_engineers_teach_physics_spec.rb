# frozen_string_literal: true

require 'rails_helper'

feature 'selecting a physics subject', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'selecting physics only' do
    when_i_visit_the_new_course_subject_page(:secondary)
    and_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_engineers_teach_physics_page(:secondary, :physics)
    and_i_click_continue
    then_i_see_an_error_message
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:secondary, :physics)
  end

  scenario 'selecting physics and modern languages subjects' do
    when_i_visit_the_new_course_subject_page(:secondary)
    and_i_select_a_subject(:physics)
    and_i_select_subordinate_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_engineers_teach_physics_with_languages_page(:secondary, :physics)
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario 'changing from physics to another course clears the campaign_name params' do
    when_i_visit_the_new_course_subject_page(:secondary)
    and_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_engineers_teach_physics_page(:secondary, :physics)
    and_i_click_continue
    then_i_see_an_error_message
    and_i_select_an_option
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:secondary, :physics)

    when_i_go_back
    when_i_go_back
    and_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_engineers_teach_physics_page_with_etp(:secondary, :physics)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:secondary, :physics)

    when_i_go_back
    when_i_go_back
    and_i_select_a_subject(:latin)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page_with_latin(:secondary, :latin)

    when_i_go_back
    and_i_select_a_subject(:physics)
    and_i_click_continue
    then_i_am_met_with_the_engineers_teach_physics_page_with_no_etp(:secondary, :physics)
    and_i_click_continue
    then_i_see_an_error_message
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_course_subject_page(level)
    publish_courses_new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: level_params(level))
  end

  def and_i_select_a_subject(subject_type)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(subject_type).subject_name).click
  end

  def and_i_click_continue
    publish_courses_new_subjects_page.continue.click
  end

  def when_i_go_back
    click_link('Back')
  end

  def and_i_select_an_option
    publish_courses_new_engineers_teach_physics_page.campaign_fields.engineers_teach_physics.click
  end

  def then_i_see_an_error_message
    expect(page).to have_content('Select if this course is part of the Engineers teach physics programme')
  end

  def and_i_select_subordinate_subject(subject_type)
    publish_courses_new_subjects_page.subordinate_subjects_fields.select(course_subject(subject_type).subject_name).click
  end

  def then_i_am_met_with_the_engineers_teach_physics_page(_level, _subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new?#{params_with_subject(:secondary, :physics)}")
    expect(page).to have_content('Engineers Teach Physics')
  end

  def then_i_am_met_with_the_engineers_teach_physics_page_with_etp(_level, _subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new?#{params_with_etp(:secondary, :physics)}")
    expect(page).to have_content('Engineers Teach Physics')
  end

  def then_i_am_met_with_the_engineers_teach_physics_page_with_no_etp(_level, _subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new?#{params_with_no_etp(:secondary, :physics)}")
    expect(page).to have_content('Engineers Teach Physics')
  end

  def then_i_am_met_with_the_engineers_teach_physics_with_languages_page(_level, _subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/engineers-teach-physics/new?#{modern_language_params_with_subject(:secondary, :physics)}")
    expect(page).to have_content('Engineers Teach Physics')
  end

  def then_i_am_met_with_the_age_range_page(level, subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new?#{params_with_etp(level, subject_type)}")
    expect(page).to have_content('Age range')
  end

  def then_i_am_met_with_the_age_range_page_with_latin(level, subject_type)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new?#{form_params_with_latin(level, subject_type)}")
    expect(page).to have_content('Age range')
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new?#{modern_languages_with_form_params(:secondary, :physics)}")
    expect(page).to have_content('Languages')
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new?#{modern_languages_with_form_params(:secondary, :physics)}")
    expect(page).to have_content('Languages')
  end

  def provider
    @provider ||= @user.providers.first
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

  def params_with_subject(level, subject_type)
    course_subject = course_subject(subject_type)
    "course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end

  def params_with_etp(level, subject_type)
    course_subject = course_subject(subject_type)
    "course%5Bcampaign_name%5D=engineers_teach_physics&course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end

  def params_with_no_etp(level, subject_type)
    course_subject = course_subject(subject_type)
    "course%5Bcampaign_name%5D=&course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end

  def modern_language_params_with_subject(level, subject_type)
    subordinate_subject = course_subject(:modern_languages)
    course_subject = course_subject(subject_type)
    "course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}"
  end

  def form_params_with_latin(level, subject_type)
    course_subject = course_subject(subject_type)
    "course%5Bcampaign_name%5D=&course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}"
  end

  def modern_languages_with_form_params(level, subject_type)
    subordinate_subject = course_subject(:modern_languages)
    course_subject = course_subject(subject_type)
    "course%5Bcampaign_name%5D=engineers_teach_physics&course%5Bis_send%5D=0&course%5Blevel%5D=#{level}&course%5Bmaster_subject_id%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{course_subject.id}&course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}"
  end
end
