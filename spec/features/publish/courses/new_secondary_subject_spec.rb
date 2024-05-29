# frozen_string_literal: true

require 'rails_helper'

feature 'selecting a subject', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'selecting one subject' do
    when_i_visit_the_new_course_subject_page
    when_i_select_one_subject(:business_studies)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:business_studies)
  end

  scenario 'selecting two subjects' do
    when_i_visit_the_new_course_subject_page
    when_i_select_two_subjects(:business_studies, :physics)
    and_i_click_continue
    then_i_am_met_with_the_age_range_page(:business_studies, :physics)
  end

  scenario 'selecting secondary subject modern languages' do
    when_i_visit_the_new_course_subject_page
    when_i_select_one_subject(:modern_languages)
    and_i_click_continue
    then_i_am_met_with_the_modern_languages_page
  end

  scenario 'selecting duplicate first and second subject' do
    when_i_visit_the_new_course_subject_page
    when_i_select_two_subjects(:business_studies, :business_studies)
    and_i_click_continue
    expect(page).to have_content('The second subject must be different to the first subject')
    expect(publish_courses_new_subjects_page.subordinate_subjects_fields.find('option[selected]')).to have_text('Business studies')
  end

  scenario 'invalid entries' do
    when_i_visit_the_new_course_subject_page
    and_i_click_continue
    then_i_am_met_with_errors
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_new_course_subject_page
    publish_courses_new_subjects_page.load(provider_code: provider.provider_code, recruitment_cycle_year: Settings.current_recruitment_cycle_year, query: secondary_subject_params)
  end

  def when_i_select_one_subject(subject_type)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(subject_type).subject_name).click
  end

  def when_i_select_two_subjects(master, subordinate)
    publish_courses_new_subjects_page.master_subject_fields.select(course_subject(master).subject_name).click
    publish_courses_new_subjects_page.subordinate_subjects_fields.select(course_subject(subordinate).subject_name).click
  end

  def and_i_click_continue
    publish_courses_new_subjects_page.continue.click
  end

  def provider
    @provider ||= @user.providers.first
  end

  def then_i_am_met_with_the_age_range_page(master, subordinate = nil)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/age-range/new?#{params_with_subject(master, subordinate)}")
    expect(page).to have_content('Age range')
  end

  def then_i_am_met_with_the_modern_languages_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/modern-languages/new?#{params_with_subject(:modern_languages)}")
    expect(page).to have_content('Languages')
  end

  def then_i_am_met_with_errors
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select a subject')
  end

  def course_subject(subject_type)
    case subject_type
    when :business_studies
      find_or_create(:secondary_subject, :business_studies)
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    end
  end

  def params_with_subject(master_subject, subordinate_subject = nil)
    master_subject = course_subject(master_subject)
    subordinate_subject = course_subject(subordinate_subject)
    if subordinate_subject
      [
        'course%5Bcampaign_name%5D=',
        'course%5Bis_send%5D=0',
        'course%5Blevel%5D=secondary',
        "course%5Bmaster_subject_id%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{subordinate_subject.id}",
        "course%5Bsubordinate_subject_id%5D=#{subordinate_subject.id}"
      ].join('&')
    else
      [
        'course%5Bcampaign_name%5D=',
        'course%5Bis_send%5D=0',
        'course%5Blevel%5D=secondary',
        "course%5Bmaster_subject_id%5D=#{master_subject.id}",
        "course%5Bsubjects_ids%5D%5B%5D=#{master_subject.id}",
        'course%5Bsubordinate_subject_id%5D='
      ].join('&')
    end
  end
end
