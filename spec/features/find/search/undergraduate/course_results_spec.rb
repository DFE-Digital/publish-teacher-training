# frozen_string_literal: true

require 'rails_helper'

feature 'Questions and results for undergraduate courses' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
  end

  after do
    Timecop.return
  end

  scenario 'with the TDA feature active and searching for secondary courses' do
    given_i_have_courses
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    then_i_am_on_the_degree_question_page

    and_i_click_continue
    then_i_see_an_error_message_on_the_degree_question_page
    and_the_back_link_points_to_the_secondary_subjects_page

    when_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_yes
    and_i_click_find_courses
    then_i_am_on_an_exit_page_for_no_degree_and_requires_visa_sponsorship

    when_i_click_back
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_no
    and_i_click_find_courses

    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
    and_i_only_see_secondary_undergraduate_courses

    when_i_uncheck_all_the_filters
    and_i_click_apply_filters
    then_i_am_on_results_page
    and_i_can_see_that_degree_is_not_required
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
  end

  scenario 'with the TDA feature active and searching primary courses' do
    given_i_have_courses
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_primary
    and_i_click_continue
    and_i_choose_primary_subjects
    and_i_click_continue
    then_i_am_on_the_degree_question_page
    and_the_back_link_points_to_the_primary_subjects_page

    when_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page

    when_i_choose_no
    and_i_click_find_courses
    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
    and_i_can_see_only_primary_undergraduate_courses

    when_i_uncheck_all_the_filters
    and_i_click_apply_filters
    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
  end

  scenario 'with the TDA feature active and searching for further education courses' do
    given_i_have_courses
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_further_education
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    when_i_choose_yes
    and_i_click_find_courses
    then_i_am_on_results_page
  end

  scenario 'with the TDA feature active and searching for postgraduate courses' do
    given_i_have_courses
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    then_i_am_on_the_degree_question_page

    when_i_choose_yes_i_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_no
    and_i_click_find_courses
    then_i_am_on_results_page
    and_all_filters_are_visible
    and_i_can_see_only_postgraduate_courses
  end

  scenario 'with the TDA feature active and searching by location' do
    given_i_have_courses_in_different_locations
    when_i_visit_the_start_page
    and_i_choose_to_find_courses_by_location
    and_i_add_a_location
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    and_i_click_continue
    then_i_see_an_error_message_on_the_degree_question_page
    and_the_back_link_points_to_the_secondary_subjects_page

    when_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_no
    and_i_click_find_courses

    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
    and_the_search_radius_filter_is_visible
    and_i_can_see_all_courses_nearer_the_radius

    when_i_select_the_most_nearer_location
    and_i_click_apply_filters
    then_i_am_on_results_page
    and_i_can_see_only_the_courses_nearer_to_the_minimum_radius_limit

    when_i_increase_the_search_radius_to_the_maximum
    and_i_click_apply_filters
    then_i_am_on_results_page
    and_i_can_see_all_courses_nearer_the_radius
  end

  scenario 'when there are no results' do
    when_i_visit_the_start_page
    and_i_choose_to_find_courses_by_location
    and_i_add_a_location
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    and_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    and_i_choose_no
    and_i_click_find_courses
    then_i_am_on_results_page
    and_i_see_the_default_message_for_no_undergraduate_courses
  end

  scenario 'when a user clicks the how to become a teacher link' do
    when_i_visit_the_start_page
    click_link_or_button 'Find out how to become a teacher.'
    and_the_link_click_is_tracked
  end

  scenario 'when a user clicks the get help and support link' do
    when_i_visit_the_start_page
    click_link_or_button 'contact Get Into Teaching'
    and_the_link_click_is_tracked
  end

  def given_i_have_courses
    provider = create(:provider)

    @biology_course = create(:course, :published_teacher_degree_apprenticeship, :secondary, provider:, name: 'Biology', subjects: [find_or_create(:secondary_subject, :biology)])
    @history_course = create(:course, :published_teacher_degree_apprenticeship, :secondary, provider:, name: 'History', subjects: [find_or_create(:secondary_subject, :history)])
    @primary_with_science_course = create(:course, :published_teacher_degree_apprenticeship, :primary, provider:, name: 'Primary with science', subjects: [find_or_create(:primary_subject, :primary_with_science)])

    @mathematics_course = create(:course, :published_postgraduate, :secondary, provider:, name: 'Mathematics', subjects: [find_or_create(:secondary_subject, :mathematics)])
    @chemistry_course = create(:course, :published_postgraduate, :secondary, provider:, name: 'Chemistry', subjects: [find_or_create(:secondary_subject, :chemistry)])
  end

  def given_i_have_courses_in_different_locations
    provider = create(:provider)

    @york_biology_course = create(
      :course,
      :published_teacher_degree_apprenticeship,
      :secondary,
      provider:,
      name: 'Biology',
      subjects: [find_or_create(:secondary_subject, :biology)],
      site_statuses: [
        build(
          :site_status,
          :findable,
          vac_status: :full_time_vacancies,
          site: build(:site, latitude: 51.4524877, longitude: -0.1204749, address1: 'AA Teamworks W Yorks SCITT, School Street, Greetland, Halifax, West Yorkshire', postcode: 'HX4 8JB')
        )
      ]
    )
    @london_biology_course = create(
      :course,
      :published_teacher_degree_apprenticeship,
      :secondary,
      provider:,
      name: 'Biology',
      subjects: [find_or_create(:secondary_subject, :biology)],
      site_statuses: [
        build(
          :site_status,
          :findable,
          vac_status: :full_time_vacancies,
          site: build(:site, latitude: 51.4980188, longitude: -0.1300436, address1: 'Westminster, London', postcode: 'SW1P 3BT')
        )
      ]
    )
  end

  def when_i_visit_the_start_page
    visit root_path
  end

  def and_i_select_the_across_england_radio_button
    choose 'Across England'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def and_i_choose_secondary
    choose 'Secondary'
  end

  def and_i_choose_primary
    choose 'Primary'
  end

  def and_i_choose_primary_subjects
    check 'Primary with science'
  end

  def and_i_choose_subjects
    check 'Biology'
    check 'Chemistry'
    check 'History'
    check 'Mathematics'
  end

  def then_i_am_on_the_degree_question_page
    expect(page).to have_current_path(
      find_university_degree_status_path,
      ignore_query: true
    )

    expect(page).to have_content('Do you have a university degree?')
  end

  def then_i_am_on_the_visa_status_page
    expect(page).to have_current_path(
      find_visa_status_path,
      ignore_query: true
    )
  end

  def and_i_choose_further_education
    choose 'Further education'
  end

  def then_i_see_an_error_message_on_the_degree_question_page
    expect(page).to have_content(
      'Select whether you have a university degree'
    )
  end

  def when_i_choose_no
    choose 'No'
  end
  alias_method :and_i_choose_no, :when_i_choose_no

  def when_i_choose_no_i_do_not_have_a_degree
    choose 'No, I do not have a degree'
  end
  alias_method :and_i_choose_no_i_do_not_have_a_degree, :when_i_choose_no_i_do_not_have_a_degree

  def when_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def then_i_am_on_an_exit_page_for_no_degree_and_requires_visa_sponsorship
    expect(page).to have_current_path(
      find_no_degree_and_requires_visa_sponsorship_path,
      ignore_query: true
    )

    expect(page).to have_content('You are not eligible for teacher training courses on this service.')
  end

  def then_i_am_on_results_page
    expect(page).to have_current_path(
      find_results_path,
      ignore_query: true
    )
  end

  def and_i_click_find_courses
    click_link_or_button 'Find courses'
  end

  def and_some_filters_are_hidden_for_undergraduate_courses
    within 'form.app-filter' do
      expect(page).to have_no_content('Study type')
      expect(page).to have_no_content('Qualifications')
      expect(page).to have_no_content('Degree grade accepted')
      expect(page).to have_no_content('Salary')
      expect(page).to have_no_content('Qualifications')
    end
  end

  def and_some_filters_are_visible_for_undergraduate_courses
    within 'form.app-filter' do
      expect(page).to have_content('Special educational needs')
      expect(page).to have_content('Applications open')
    end
  end

  def and_i_can_see_only_primary_undergraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Primary with science')
      expect(page).to have_content(@primary_with_science_course.course_code)
      expect(page).to have_no_content('Biology')
      expect(page).to have_no_content(@biology_course.course_code)
      expect(page).to have_no_content('History')
      expect(page).to have_no_content(@history_course.course_code)
      expect(page).to have_no_content('Chemistry')
      expect(page).to have_no_content(@chemistry_course.course_code)
      expect(page).to have_no_content('Mathematics')
      expect(page).to have_no_content(@mathematics_course.course_code)
    end
  end

  def and_i_only_see_secondary_undergraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Biology')
      expect(page).to have_content(@biology_course.course_code)
      expect(page).to have_content('History')
      expect(page).to have_content(@history_course.course_code)
      expect(page).to have_no_content('Primary with science')
      expect(page).to have_no_content(@primary_with_science_course.course_code)
      expect(page).to have_no_content('Chemistry')
      expect(page).to have_no_content(@chemistry_course.course_code)
      expect(page).to have_no_content('Mathematics')
      expect(page).to have_no_content(@mathematics_course.course_code)
    end
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def and_the_back_link_points_to_the_degree_question
    expect(back_link[:href]).to include(find_university_degree_status_path)
  end

  def and_the_back_link_points_to_the_secondary_subjects_page
    expect(back_link[:href]).to include(find_subjects_path(age_group: 'secondary'))
  end

  def and_the_back_link_points_to_the_primary_subjects_page
    expect(back_link[:href]).to include(find_subjects_path(age_group: 'primary'))
  end

  def and_all_filters_are_visible
    within 'form.app-filter' do
      expect(page).to have_content('Study type')
      expect(page).to have_content('Qualifications')
      expect(page).to have_content('Degree grade accepted')
      expect(page).to have_content('Salary')
      expect(page).to have_content('Qualifications')
      expect(page).to have_content('Special educational needs')
      expect(page).to have_content('Applications open')
    end
  end

  def and_i_can_see_only_postgraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Chemistry')
      expect(page).to have_content(@chemistry_course.course_code)
      expect(page).to have_content('Mathematics')
      expect(page).to have_content(@mathematics_course.course_code)
      expect(page).to have_no_content('Biology')
      expect(page).to have_no_content(@biology_course.course_code)
      expect(page).to have_no_content('History')
      expect(page).to have_no_content(@history_course.course_code)
      expect(page).to have_no_content('Primary with science')
      expect(page).to have_no_content(@primary_with_science_course.course_code)
    end
  end

  def back_link
    page.find_link('Back')
  end

  def when_i_uncheck_all_the_filters
    uncheck 'Only show courses open for applications'
    uncheck 'Only show courses with a SEND specialism'
  end

  def and_i_can_see_that_degree_is_not_required
    expect(page).to have_content(
      "Degree required\nNo degree required\n"
    ).twice
  end

  def and_i_click_apply_filters
    click_link_or_button 'Apply filters'
  end

  def and_i_choose_to_find_courses_by_location
    stub_geocoder_lookup
    choose 'By city, town or postcode'
  end

  def and_i_add_a_location
    fill_in 'Postcode, town or city', with: 'Yorkshire'
  end

  def and_the_search_radius_filter_is_visible
    within 'form.app-filter' do
      expect(page).to have_content('Search radius')
    end
  end

  def when_i_select_the_most_nearer_location
    select '1 mile', from: 'Search radius'
  end

  def and_i_can_see_all_courses_nearer_the_radius
    within '.app-search-results' do
      expect(page).to have_content('Biology')
      expect(page).to have_content(@york_biology_course.course_code)
      expect(page).to have_content(@london_biology_course.course_code)
    end
  end

  def and_i_can_see_only_the_courses_nearer_to_the_minimum_radius_limit
    within '.app-search-results' do
      expect(page).to have_content('Biology')
      expect(page).to have_content(@york_biology_course.course_code)
      expect(page).to have_no_content(@london_biology_course.course_code)
    end
  end

  def when_i_increase_the_search_radius_to_the_maximum
    select '200 miles', from: 'Search radius'
  end

  def and_i_see_the_default_message_for_no_undergraduate_courses
    expect(page).to have_content(
      'There are not many teacher degree apprenticeship (TDA) courses on the service at the moment. You can try again soon when there may be more courses, or get in touch with us at becomingateacher@digital.education.gov.uk.'
    )
    expect(page).to have_content(
      'Find out more about teacher degree apprenticeship (TDA) courses.'
    )
  end

  def and_the_link_click_is_tracked
    expect(:track_click).to have_been_enqueued_as_analytics_events
  end
end
