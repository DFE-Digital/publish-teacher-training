# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search results tracking', :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)

    double = instance_double(Find::Analytics::SearchResultsEvent)
    allow(Find::Analytics::SearchResultsEvent).to receive(:new).and_return(double)
    allow(double).to receive(:send_event)

    given_some_courses_exist
  end

  context 'from homepage' do
    before { when_i_visit_the_homepage }

    scenario 'when searching from the homepage form' do
      when_i_click_search
      then_one_search_result_is_tracked_from_homepage_form
      and_i_am_on_the_results_page
    end

    scenario 'when browse primary courses' do
      when_i_browse_primary_courses
      and_i_choose_primary
      and_i_click_find_primary_courses
      then_one_search_result_is_tracked_from_primary_courses_form
      and_i_am_on_the_results_page
    end

    scenario 'when browse secondary courses' do
      when_i_browse_secondary_courses
      and_i_choose_art_and_design
      and_i_click_find_secondary_courses
      then_one_search_result_is_tracked_from_secondary_courses_form
      and_i_am_on_the_results_page
    end

    scenario 'when browse teacher degree apprenticeship courses' do
      when_i_browse_teacher_degree_apprenticeship_courses
      then_one_search_result_is_tracked_from_teacher_degree_apprenticeship_link
      and_i_am_on_the_results_page
    end

    scenario 'when browse SEND primary courses' do
      when_i_browse_send_primary_courses
      then_one_search_result_is_tracked_from_send_primary_link
      and_i_am_on_the_results_page
    end

    scenario 'when browse SEND secondary courses' do
      when_i_browse_send_secondary_courses
      then_one_search_result_is_tracked_from_send_secondary_link
      and_i_am_on_the_results_page
    end

    scenario 'when browse further education courses' do
      when_i_browse_further_education_courses
      then_one_search_result_is_tracked_from_further_education_link
      and_i_am_on_the_results_page
    end
  end

  context 'when searching from the results page' do
    before { when_i_visit_the_results_page }

    scenario 'when applying filters' do
      and_i_filter_for_primary_courses
      and_i_apply_filters_using_the_top_button
      then_search_result_is_tracked_with_applied_filters_with_top_applied_filter

      when_i_apply_filters_using_the_bottom_button
      then_search_result_is_tracked_with_applied_filters_with_bottom_applied_filter
    end

    scenario 'when searching within the results page' do
      when_i_filter_for_send_courses
      and_i_search_for_art_and_design_subject
      and_i_click_search
      then_search_result_is_tracked_with_new_search
    end

    scenario 'when sorting courses' do
      when_i_sort_by_provider_ascending
      and_i_click_sort
      then_search_result_order_is_tracked
    end

    scenario 'when bookmarking search results page' do
      when_i_visit_the_results_page_bookmarked_an_old_tracked_url
      then_search_result_is_tracked_with_new_search_using_results_as_utm_medium
    end
  end

  def given_some_courses_exist
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :open,
      name: 'Biology',
      course_code: '2DTK',
      provider: build(:provider, provider_name: 'London university', provider_code: '19S')
    )
    create(
      :course,
      :with_full_time_sites,
      :published_teacher_degree_apprenticeship,
      :secondary,
      :open,
      name: 'Mathematics',
      course_code: 'TDA1',
      provider: build(:provider, provider_name: 'Bristol university', provider_code: '23T'),
      degree_grade: 'not_required'
    )
    create(
      :course,
      :with_full_time_sites,
      :primary,
      :open,
      :with_special_education_needs,
      name: 'Primary (SEND)',
      course_code: 'P123',
      provider: build(:provider, provider_name: 'Bath university', provider_code: 'PO1')
    )
    create(
      :course,
      :with_full_time_sites,
      :secondary,
      :open,
      :with_special_education_needs,
      name: 'Art and design (SEND)',
      course_code: 'F314',
      provider: build(:provider, provider_name: 'York university', provider_code: 'RO1'),
      subjects: [find_or_create(:secondary_subject, :art_and_design)]
    )
    create(
      :course,
      :with_full_time_sites,
      :open,
      name: 'Further Education',
      course_code: 'F3D',
      provider: build(:provider, provider_name: 'Birmingham university', provider_code: 'JL1'),
      level: 'further_education'
    )
    create(
      :course,
      :with_full_time_sites,
      :primary,
      :open,
      name: 'Primary',
      course_code: 'Y565',
      provider: build(:provider, provider_name: 'Brighton university', provider_code: '1UR')
    )

    subject_group = create(:subject_group, name: 'Arts, humanities and social sciences')
    find_or_create(:secondary_subject, :art_and_design).update(subject_group:)
  end

  def when_i_visit_the_homepage
    visit root_path
  end

  def when_i_click_search
    click_link_or_button 'Search'
  end

  def then_one_search_result_is_tracked_from_homepage_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 6,
          page: 1,
          search_params: hash_including(applications_open: true),
          track_params: hash_including(utm_source: 'home', utm_medium: 'main_search'),
          results: array_including(
            have_attributes(course_code: 'F314', provider_code: 'RO1'),
            have_attributes(course_code: '2DTK', provider_code: '19S'),
            have_attributes(course_code: 'F3D', provider_code: 'JL1'),
            have_attributes(course_code: 'TDA1', provider_code: '23T'),
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      )
    end
  end

  def and_i_am_on_the_results_page
    expect(page).to have_current_path(find_results_path, ignore_query: true)
  end

  def when_i_browse_primary_courses
    click_link_or_button 'Browse primary courses'
  end

  def and_i_choose_primary
    check 'Primary', visible: :all
  end

  def and_i_click_find_primary_courses
    click_link_or_button 'Find primary courses'
  end

  def then_one_search_result_is_tracked_from_primary_courses_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 2,
          page: 1,
          search_params: hash_including(applications_open: true, subjects: ['00']),
          track_params: hash_including(utm_source: 'home', utm_medium: 'primary_courses'),
          results: array_including(
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      )
    end
  end

  def when_i_browse_secondary_courses
    click_link_or_button 'Browse secondary courses'
  end

  def and_i_choose_art_and_design
    check 'Art and design', visible: :all
  end

  def and_i_click_find_secondary_courses
    click_link_or_button 'Find secondary courses'
  end

  def then_one_search_result_is_tracked_from_secondary_courses_form
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, subjects: ['W1']),
          track_params: hash_including(utm_source: 'home', utm_medium: 'secondary_courses'),
          results: array_including(
            have_attributes(course_code: 'F314', provider_code: 'RO1')
          )
        )
      )
    end
  end

  def and_all_accordions_are_open
    page.all('.govuk-accordion__section-button').map(&:click)
  end

  def when_i_browse_teacher_degree_apprenticeship_courses
    and_all_accordions_are_open
    click_link_or_button 'Browse teacher degree apprenticeship courses.'
  end

  def then_one_search_result_is_tracked_from_teacher_degree_apprenticeship_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, minimum_degree_required: 'no_degree_required'),
          track_params: hash_including(utm_source: 'home', utm_medium: 'teacher_degree_apprenticeship_courses'),
          results: array_including(
            have_attributes(course_code: 'TDA1', provider_code: '23T')
          )
        )
      )
    end
  end

  def when_i_browse_send_primary_courses
    and_all_accordions_are_open
    click_link_or_button 'Browse primary courses with a SEND specialism.'
  end

  def when_i_browse_send_secondary_courses
    and_all_accordions_are_open
    click_link_or_button 'Browse secondary courses with a SEND specialism.'
  end

  def then_one_search_result_is_tracked_from_send_primary_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, send_courses: true, subjects: Subject.primary_subject_codes),
          track_params: hash_including(utm_source: 'home', utm_medium: 'send_primary_courses'),
          results: array_including(
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      )
    end
  end

  def then_one_search_result_is_tracked_from_send_secondary_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, send_courses: true, subjects: Subject.secondary_subject_codes_with_incentives),
          track_params: hash_including(utm_source: 'home', utm_medium: 'send_secondary_courses'),
          results: array_including(
            have_attributes(course_code: 'F314', provider_code: 'RO1')
          )
        )
      )
    end
  end

  def when_i_browse_further_education_courses
    and_all_accordions_are_open
    click_link_or_button 'Browse further education courses.'
  end

  def then_one_search_result_is_tracked_from_further_education_link
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(applications_open: true, level: 'further_education'),
          track_params: hash_including(utm_source: 'home', utm_medium: 'further_education_courses'),
          results: array_including(
            have_attributes(course_code: 'F3D', provider_code: 'JL1')
          )
        )
      )
    end
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def and_i_filter_for_primary_courses
    check 'Primary', visible: :all
  end

  def and_i_apply_filters_using_the_top_button
    click_link_or_button 'Apply filters', match: :first
  end

  def then_search_result_is_tracked_with_applied_filters_with_top_applied_filter
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 2,
          page: 1,
          search_params: hash_including(order: 'course_name_ascending', subjects: ['00']),
          track_params: hash_including(utm_source: 'results', utm_medium: 'apply_filters_top'),
          results: array_including(
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      )
    end
  end

  def when_i_apply_filters_using_the_bottom_button
    page.all('button', text: 'Apply filters').last.click
  end

  def then_search_result_is_tracked_with_applied_filters_with_bottom_applied_filter
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 2,
          page: 1,
          search_params: hash_including(order: 'course_name_ascending', subjects: ['00']),
          track_params: hash_including(utm_source: 'results', utm_medium: 'apply_filters_bottom'),
          results: array_including(
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      )
    end
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

  def then_search_result_is_tracked_with_new_search
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 1,
          page: 1,
          search_params: hash_including(order: 'course_name_ascending', subject_code: 'W1', subject_name: 'Art and design', send_courses: true),
          track_params: hash_including(utm_source: 'results', utm_medium: 'search'),
          results: array_including(
            have_attributes(course_code: 'F314', provider_code: 'RO1')
          )
        )
      )
    end
  end

  def when_i_sort_by_provider_ascending
    select 'Training provider (A-Z)'
  end

  def and_i_click_sort
    click_link_or_button 'Sort'
  end

  def then_search_result_order_is_tracked
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(
          total: 6,
          page: 1,
          search_params: hash_including(order: 'provider_name_ascending'),
          track_params: hash_including(utm_source: 'results', utm_medium: 'sort'),
          results: array_including(
            have_attributes(course_code: 'P123', provider_code: 'PO1'),
            have_attributes(course_code: 'F3D', provider_code: 'JL1'),
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'TDA1', provider_code: '23T'),
            have_attributes(course_code: '2DTK', provider_code: '19S'),
            have_attributes(course_code: 'F314', provider_code: 'RO1')
          )
        )
      )
    end
  end

  def when_i_visit_the_results_page_bookmarked_an_old_tracked_url
    visit find_results_path(utm_source: 'home', utm_medium: 'main_search')
  end

  def then_search_result_is_tracked_with_new_search_using_results_as_utm_medium
    wait_for do
      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).twice.with(
        hash_including(
          total: 6,
          page: 1,
          search_params: {},
          track_params: an_instance_of(ActionController::Parameters),
          results: array_including(
            have_attributes(course_code: 'F314', provider_code: 'RO1'),
            have_attributes(course_code: '2DTK', provider_code: '19S'),
            have_attributes(course_code: 'F3D', provider_code: 'JL1'),
            have_attributes(course_code: 'TDA1', provider_code: '23T'),
            have_attributes(course_code: 'Y565', provider_code: '1UR'),
            have_attributes(course_code: 'P123', provider_code: 'PO1')
          )
        )
      ).twice
    end
  end
end
