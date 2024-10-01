# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Back to results back button' do
  include FiltersFeatureSpecsHelper
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_there_are_primary_courses_in_england
    allow_any_instance_of(Find::ViewHelper).to receive(:permitted_referrer?).and_return(true)
  end

  scenario 'Candidate selects a course, selects the provider, then clicks back to the course and then back to the results page' do
    when_i_visit_the_start_page

    and_i_select_the_across_england_radio_button
    and_i_click_continue

    and_i_select_the_primary_subject_textbox
    and_i_click_continue

    and_i_select_the_primary_subject_checkbox
    and_i_click_continue

    and_i_choose_yes_i_have_a_degree
    and_i_click_continue

    and_i_select_my_visa_status
    and_i_click_find_courses

    and_i_see_the_number_of_courses

    i_select_a_course
    i_click_on_the_provider_name

    i_click_on_back_button_to_course
    i_click_on_back_to_results

    and_then_i_am_taken_back_to_the_results_page
  end

  private

  def given_there_are_primary_courses_in_england
    @primary_course = create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
    create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])

    create(:course, :secondary, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
  end

  def and_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
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

  def and_i_select_the_primary_subject_textbox
    choose 'Primary'
  end

  def and_i_select_the_primary_subject_checkbox
    check 'Primary'
  end

  def and_i_select_my_visa_status
    choose 'No'
  end

  def and_i_click_find_courses
    click_link_or_button 'Find courses'
  end
  alias_method :when_i_click_find_courses, :and_i_click_find_courses

  def and_i_see_the_number_of_courses
    expect(find_results_page.courses.count).to eq(2)
  end

  def i_select_a_course
    click_link_or_button @primary_course.name
  end

  def i_click_on_the_provider_name
    click_link_or_button @primary_course.provider.provider_name
  end

  def i_click_on_back_button_to_course
    click_link_or_button "Back to #{@primary_course.name}"
  end

  def i_click_on_back_to_results
    click_link_or_button 'Back to search results'
  end

  def and_then_i_am_taken_back_to_the_results_page
    expect(page).to have_current_path(find_results_path)
  end
end
