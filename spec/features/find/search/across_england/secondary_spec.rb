# frozen_string_literal: true

require 'rails_helper'

feature 'Searching across England' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_secondary_courses_in_england
  end

  scenario 'Candidate searches for secondary courses across England' do
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_correct_age_group_form_page_url_and_query_params_are_present

    when_i_select_the_secondary_radio_button
    and_i_click_continue
    then_i_should_see_the_subjects_form
    and_the_correct_subjects_form_page_url_and_query_params_are_present

    when_i_click_back
    then_i_should_see_the_age_groups_form
    and_age_group_radio_selected

    when_i_click_continue
    then_i_should_see_the_subjects_form

    when_i_click_continue
    then_i_should_see_a_subjects_validation_error

    when_i_select_the_secondary_subject
    and_i_click_continue
    and_i_choose_yes_i_have_a_degree
    and_i_click_continue
    then_i_should_see_the_visa_status_page

    when_i_choose_no_to_visa_sponsorship

    and_i_click_find_courses
    then_i_should_see_the_find_results_page
    and_i_should_see_the_correct_courses
    and_i_see_that_the_visa_checkbox_is_not_checked
  end

  context 'Given the bursaries and scholarships announced feature flag' do
    context 'when deactivated' do
      before do
        given_the_bursaries_and_scholarships_feature_flag_is_deactivated
      end

      scenario 'displays the financial support banner' do
        when_i_visit_the_secondary_subjects_page
        then_i_should_see_the_financial_support_banner
      end
    end

    context 'when activated' do
      before do
        given_the_bursaries_and_scholarships_feature_flag_is_activated
      end

      scenario 'does not display the financial support banner' do
        when_i_visit_the_secondary_subjects_page
        then_i_should_not_see_the_financial_support_banner
      end
    end
  end

  private

  def and_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
  end

  def and_i_see_that_the_visa_checkbox_is_not_checked
    expect(page).to have_no_checked_field('Only show courses with visa sponsorship')
  end

  def given_the_bursaries_and_scholarships_feature_flag_is_deactivated
    FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
  end

  def given_the_bursaries_and_scholarships_feature_flag_is_activated
    FeatureFlag.activate(:bursaries_and_scholarships_announced)
  end

  def then_i_should_see_the_financial_support_banner
    expect(page).to have_css('.govuk-notification-banner__heading', text: 'Financial support')
  end

  def then_i_should_not_see_the_financial_support_banner
    expect(page).to have_no_css('.govuk-notification-banner__heading', text: 'Financial support')
  end

  def when_i_visit_the_secondary_subjects_page
    find_secondary_subjects_page.load
  end

  def given_there_are_secondary_courses_in_england
    create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
    @secondary_biology_course = create(:course, :secondary, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)], subjects: [find_or_create(:secondary_subject, :biology)])
    @secondary_chemistry_course = create(:course, :secondary, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)], subjects: [find_or_create(:secondary_subject, :chemistry)])
  end

  def when_i_visit_the_start_page
    find_courses_by_location_or_training_provider_page.load
  end

  def and_i_select_the_across_england_radio_button
    find_courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def and_age_group_radio_selected
    expect(find_field('Secondary')).to be_checked
  end

  def then_i_should_see_the_age_groups_form
    expect(page).to have_content(I18n.t('find.age_groups.title'))
  end

  def and_the_correct_age_group_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/age-groups')
      expect(uri.query).to eq('l=2')
    end
  end

  def and_the_correct_subjects_form_page_url_and_query_params_are_present
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/subjects')
      expect(uri.query).to eq('age_group=secondary&l=2')
    end
  end

  def when_i_select_the_secondary_radio_button
    choose 'Secondary'
  end

  def then_i_should_see_the_subjects_form
    expect(page).to have_content('Which secondary subjects do you want to teach?')
  end

  def and_i_click_find_courses
    click_link_or_button 'Find courses'
  end
  alias_method :when_i_click_find_courses, :and_i_click_find_courses

  def then_i_should_see_a_subjects_validation_error
    expect(page).to have_content('Select at least one secondary subject you want to teach')
  end

  def when_i_select_the_secondary_subject
    check 'Biology'
  end

  def then_i_should_see_the_visa_status_page
    expect(page).to have_content('Do you need visa sponsorship?')
  end

  def when_i_choose_no_to_visa_sponsorship
    choose 'No'
  end

  def then_i_should_see_the_find_results_page
    expect(page).to have_current_path('/results?age_group=secondary&applications_open=true&can_sponsor_visa=false&has_vacancies=true&l=2&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time&subjects%5B%5D=C1&university_degree_status=true&visa_status=false')
  end

  def and_i_should_see_the_correct_courses
    expect(find_results_page.courses.count).to eq(1)

    find_results_page.courses.first.then do |first_course|
      expect(first_course.course_name.text).to include(@secondary_biology_course.name)
    end
  end
end
