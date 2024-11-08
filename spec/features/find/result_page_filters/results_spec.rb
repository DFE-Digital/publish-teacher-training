# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Results page' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  scenario 'Candidate visits the results page when there are no search results' do
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

    and_i_see_no_results
  end

  scenario 'Candidate visits the results page when there are search results' do
    given_there_are_primary_courses_in_england

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

    and_i_see_search_results
  end

  def when_i_visit_the_start_page
    find_courses_by_location_or_training_provider_page.load
  end

  def and_i_click_find_courses
    click_link_or_button 'Find courses'
  end
  alias_method :when_i_click_find_courses, :and_i_click_find_courses

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def given_there_are_primary_courses_in_england
    @primary_course = create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
    create(:course, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])

    create(:course, :secondary, :published, :with_salary, application_status: 'open', site_statuses: [build(:site_status, :findable)])
  end

  def and_i_select_the_across_england_radio_button
    find_courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_select_the_primary_subject_textbox
    choose 'Primary'
  end

  def and_i_select_the_primary_subject_checkbox
    check 'Primary'
  end

  def and_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
  end

  def and_i_select_my_visa_status
    choose 'No'
  end

  def and_i_see_no_results
    expect(page).to have_text('No courses found')
  end

  def and_i_see_search_results
    expect(page).to have_text('2 courses found')
  end
end
