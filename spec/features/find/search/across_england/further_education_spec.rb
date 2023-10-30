# frozen_string_literal: true

require 'rails_helper'

feature 'Searching across England' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_further_education_courses_in_england
  end

  scenario 'Candidate searches for further education courses across England' do
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_correct_age_group_form_page_url_and_query_params_are_present

    when_i_select_the_further_education_radio_button
    and_i_click_continue
    then_i_should_see_the_visa_status_page

    when_i_select_my_visa_status
    and_i_click_find_courses
    then_i_should_see_the_find_results_page
  end

  private

  def given_there_are_further_education_courses_in_england
    create(:course, :published, :with_salary, site_statuses: [build(:site_status, :findable)])
    create(:course, :secondary, :published, :with_salary, site_statuses: [build(:site_status, :findable)], subjects: [find_or_create(:secondary_subject, :biology)])
    @further_education_course = create(:course, :published, level: 'further_education', site_statuses: [build(:site_status, :findable)], subjects: [find_or_create(:further_education_subject)])
  end

  def when_i_visit_the_start_page
    find_courses_by_location_or_training_provider_page.load
  end

  def and_i_select_the_across_england_radio_button
    find_courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_click_continue
    click_button 'Continue'
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

  def when_i_select_the_further_education_radio_button
    choose 'Further education'
  end

  def then_i_should_see_the_visa_status_page
    expect(page).to have_content('Do you need visa sponsorship?')
  end

  def when_i_select_my_visa_status
    choose 'No'
  end

  def and_i_click_find_courses
    click_button 'Find courses'
  end

  def then_i_should_see_the_find_results_page
    expect(page).to have_current_path('/results?age_group=further_education&applications_open=true&can_sponsor_visa=false&has_vacancies=true&l=2&subjects%5B%5D=41&visa_status=false')
  end

  def and_i_should_see_the_correct_courses
    expect(find_results_page.courses.count).to eq(1)

    find_results_page.courses.first.then do |first_course|
      expect(first_course.course_name.text).to include(@further_education_course.name)
    end
  end
end
