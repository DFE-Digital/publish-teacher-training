# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2 results - enabled', :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive_messages(v2_results: true)

    given_courses_exist_in_various_locations
    when_i_visit_the_results_page
  end

  scenario 'when I filter by location' do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_london_location
    then_i_see_autocomplete_suggestions

    when_i_select_the_first_suggestion
    and_i_click_search
    then_i_see_only_courses_within_selected_location_within_default_radius
  end

  def given_courses_exist_in_various_locations
    london = build(:location, :london)
    romford = build(:location, :romford)
    watford = build(:location, :watford)
    primary_subject = find_or_create(:primary_subject, :primary)
    mathematics_subject = find_or_create(:secondary_subject, :mathematics)

    @london_primary_course = create(
      :course,
      :primary,
      name: 'Primary - London',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
      subjects: [primary_subject]
    )

    @romford_primary_course = create(
      :course,
      :primary,
      name: 'Primary - Romford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))],
      subjects: [primary_subject]
    )

    @watford_primary_course = create(
      :course,
      :primary,
      name: 'Primary - Watford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: watford.latitude, longitude: watford.longitude))],
      subjects: [primary_subject]
    )

    @london_secondary_course = create(
      :course,
      :secondary,
      name: 'Mathematics - London',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
      subjects: [mathematics_subject]
    )

    @romford_secondary_course = create(
      :course,
      :secondary,
      name: 'Mathematics - Romford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))],
      subjects: [mathematics_subject]
    )

    @watford_secondary_course = create(
      :course,
      :secondary,
      name: 'Mathematics - Watford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: watford.latitude, longitude: watford.longitude))],
      subjects: [mathematics_subject]
    )
  end

  def when_i_visit_the_results_page
    visit find_v2_results_path
  end

  def when_i_start_typing_an_invalid_location
    fill_in 'City, town or postcode', with: 'NonExistentCity'
  end

  def then_i_see_no_autocomplete_suggestions
    expect(page).to have_css('#location-field__listbox', visible: :hidden)
  end

  def when_i_start_typing_london_location
    stub_request(
      :get,
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:uk&input=Lon&key=replace_me&language=en&types=geocode'
    ).with(
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Connection' => 'keep-alive',
        'Keep-Alive' => '30',
        'User-Agent' => 'Faraday v2.12.2'
      }
    ).to_return(status: 200, body: { predictions: [{ description: 'London, UK' }] }.to_json, headers: { 'Content-Type' => 'application/json' })

    fill_in 'City, town or postcode', with: 'Lon'
  end

  def then_i_see_autocomplete_suggestions
    expect(page).to have_css('#location-field__listbox', visible: :visible)
    expect(page.find_by_id('location-field__listbox')).to have_content('London, UK')
  end

  def when_i_select_the_first_suggestion
    page.find_by_id('location-field__option--0').click
  end

  def and_i_click_search
    click_link_or_button 'Search'
  end

  def then_i_see_only_courses_within_selected_location_within_default_radius
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_content(@london_secondary_course.name_and_code)

    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
  end

  def results
    page.first('.app-search-results')
  end

  scenario 'when I filter by location and subject' do
    when_i_search_for_courses_in_london
    and_select_primary_subject
    then_i_see_only_courses_within_selected_location_and_primary_subject_within_default_radius
  end

  scenario 'when I filter by location, subject, and radius' do
    when_i_enter_a_valid_location
    and_select_primary_subject
    and_select_one_mile_radius
    then_i_see_only_courses_within_selected_location_and_primary_subject_within_one_mile
  end

  scenario 'when I filter by subject' do
    given_courses_exist_with_various_subjects
    and_the_subject_input_field_is_visible
    when_i_select_a_subject
    then_i_see_only_courses_with_selected_subject
  end

  scenario 'when search results update after filter changes' do
    when_i_change_filters_and_search
    then_i_see_updated_search_results_based_on_selected_filters
  end
end
