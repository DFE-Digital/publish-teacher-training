# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2 results - view a course', :js, service: :find do
  include FiltersFeatureSpecsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive_messages(v2_results: true)

    given_courses_exist
    when_i_visit_the_results_page
  end

  scenario 'viewing a course from the search results' do
    when_i_filter_for_send_courses
    and_i_search_for_art_and_design_subject
    and_i_click_search
    and_i_click_on_the_first_result
    and_i_am_on_the_course_page

    when_i_click_back_to_results
    then_i_am_on_search_results_page_with_the_applied_search
  end

  def given_courses_exist
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      name: 'Art and design (SEND)',
      course_code: 'F314',
      provider: build(:provider, provider_name: 'York university', provider_code: 'RO1'),
      subjects: [find_or_create(:secondary_subject, :art_and_design)]
    )
  end

  def when_i_visit_the_results_page
    visit(find_v2_results_path)
  end

  def when_i_filter_for_send_courses
    check 'Only show courses with a SEND specialism', visible: :all
  end

  def and_i_search_for_art_and_design_subject
    fill_in 'Subject', with: 'Art'

    and_i_choose_the_first_subject_suggestion
  end

  def and_i_choose_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def and_i_click_search
    click_link_or_button 'Search'
  end

  def and_i_click_on_the_first_result
    page.first('.app-search-results').first('a').click
  end

  def and_i_am_on_the_course_page
    expect(page).to have_current_path(
      find_course_path(
        provider_code: 'RO1',
        course_code: 'F314'
      )
    )
  end

  def when_i_click_back_to_results
    click_link_or_button 'Back to search results'
  end

  def then_i_am_on_search_results_page_with_the_applied_search
    expect(page).to have_current_path(find_v2_results_path, ignore_query: true)

    expect(
      query_params(URI(page.current_url)).symbolize_keys
    ).to eq(
      {
        send_courses: 'true',
        subject_name: 'Art and design',
        subject_code: 'W1',
        location: '',
        radius: '10',
        order: ''
      }
    )
  end
end
