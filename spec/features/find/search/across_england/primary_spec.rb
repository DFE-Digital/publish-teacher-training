# frozen_string_literal: true

require 'rails_helper'

feature 'Searching across England' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_primary_courses_in_england
  end

  scenario 'Candidate searches for primary courses across England' do
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_correct_age_group_form_page_url_and_query_params_are_present

    when_i_click_back
    then_i_should_see_the_start_page
    and_the_across_england_radio_button_is_selected

    when_i_click_continue
    then_i_should_see_the_age_groups_form

    when_i_click_continue
    i_should_see_an_age_group_validation_error

    when_i_select_the_primary_radio_button
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

    when_i_select_the_primary_subject_textbox
    and_i_click_continue

    and_i_choose_yes_i_have_a_degree
    and_i_click_continue

    then_i_should_see_the_visa_status_page

    when_i_click_find_courses
    then_i_should_see_a_validation_error

    when_i_click_back
    and_i_click_back
    then_i_should_see_the_subjects_form
    and_i_click_continue

    and_i_choose_yes_i_have_a_degree
    and_i_click_continue

    when_i_select_my_visa_status
    and_i_click_find_courses
    then_i_should_see_the_find_results_page
    and_i_should_see_the_correct_courses
  end

  private

  def given_there_are_primary_courses_in_england
    @primary_course = create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
    create(:course, :secondary, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
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

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_click_continue
    and_i_click_continue
  end

  def then_i_should_see_the_start_page
    expect(find_courses_by_location_or_training_provider_page).to be_displayed
  end

  def and_the_across_england_radio_button_is_selected
    expect(find_courses_by_location_or_training_provider_page.across_england).to be_checked
  end

  def and_age_group_radio_selected
    expect(find_field('Primary')).to be_checked
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
      expect(uri.query).to eq('age_group=primary&has_vacancies=true&l=2&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time')
    end
  end

  def i_should_see_an_age_group_validation_error
    expect(page).to have_content('Select which age group you want to teach')
  end

  def when_i_select_the_primary_radio_button
    choose 'Primary'
  end

  def then_i_should_see_the_subjects_form
    expect(page).to have_content('Primary courses with subject specialisms')
  end

  def and_i_click_find_courses
    click_link_or_button 'Find courses'
  end
  alias_method :when_i_click_find_courses, :and_i_click_find_courses

  alias_method :and_i_click_back, :when_i_click_back

  def then_i_should_see_a_subjects_validation_error
    expect(page).to have_content('Select at least one primary subject you want to teach')
  end

  def when_i_select_the_primary_subject_textbox
    check 'Primary'
  end

  def then_i_should_see_the_visa_status_page
    expect(page).to have_content('Do you need visa sponsorship?')
  end

  def and_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
  end

  def when_i_select_my_visa_status
    choose 'No'
  end

  def then_i_should_see_a_validation_error
    expect(page).to have_content('Select if you have the right to work or study in the UK')
  end

  def then_i_should_see_the_find_results_page
    expect(page).to have_current_path('/results?age_group=primary&applications_open=true&can_sponsor_visa=false&has_vacancies=true&l=2&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time&subjects%5B%5D=00&university_degree_status=true&visa_status=false')
  end

  def and_i_should_see_the_correct_courses
    expect(find_results_page.courses.count).to eq(1)

    find_results_page.courses.first.then do |first_course|
      expect(first_course.course_name.text).to include(@primary_course.name)
    end
  end
end
