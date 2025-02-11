# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2 results - enabled', :js, service: :find do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    allow(Settings.features).to receive_messages(v2_results: true)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    given_courses_exist_in_various_locations
    when_i_visit_the_results_page
  end

  scenario 'when I filter by location' do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_london_location
    then_i_see_location_suggestions

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london
    then_i_see_only_courses_within_selected_location_within_default_radius
    and_the_default_radius_is_selected

    when_i_increase_the_radius_to_15_miles
    and_i_click_search
    then_i_see_courses_up_to_15_miles_distance
    and_the_15_miles_radius_is_selected

    when_i_increase_the_radius_to_20_miles
    and_i_click_search
    then_i_see_courses_up_to_20_miles_distance
    and_the_20_miles_radius_is_selected
  end

  scenario 'when I filter by location and subject' do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_london_location
    then_i_see_location_suggestions

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london
    then_i_see_only_courses_within_selected_location_within_default_radius

    and_select_primary_subject
    and_i_click_search
    then_i_see_only_courses_within_selected_location_and_primary_subject_within_default_radius
  end

  scenario 'when I filter by subject' do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion
    and_i_click_search
    then_i_see_only_mathematics_courses
  end

  scenario 'when search results update after filter changes' do
    when_i_search_for_math
    and_i_choose_the_first_subject_suggestion

    when_i_start_typing_london_location
    then_i_see_location_suggestions

    when_i_select_the_first_suggestion
    and_i_increase_the_radius_to_15_miles
    and_i_click_to_search_courses_in_london

    when_i_filter_by_courses_that_sponsor_visa
    and_i_click_apply_filters

    then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
  end

  def given_courses_exist_in_various_locations
    london = build(:location, :london)
    romford = build(:location, :romford)
    watford = build(:location, :watford)
    edinburgh = build(:location, :edinburgh)
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

    @edinburgh_mathematics_course = create(
      :course,
      :primary,
      :can_not_sponsor_visa,
      name: 'Primary - Edinburgh',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude))],
      subjects: [primary_subject]
    )

    @london_mathematics_course = create(
      :course,
      :secondary,
      name: 'Mathematics - London',
      can_sponsor_student_visa: true,
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
      subjects: [mathematics_subject]
    )

    @romford_mathematics_course = create(
      :course,
      :secondary,
      :can_not_sponsor_visa,
      name: 'Mathematics - Romford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: romford.latitude, longitude: romford.longitude))],
      subjects: [mathematics_subject]
    )

    @watford_mathematics_course = create(
      :course,
      :secondary,
      :can_not_sponsor_visa,
      name: 'Mathematics - Watford',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: watford.latitude, longitude: watford.longitude))],
      subjects: [mathematics_subject]
    )

    @edinburgh_mathematics_course = create(
      :course,
      :secondary,
      :can_not_sponsor_visa,
      name: 'Mathematics - Edinburgh',
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude))],
      subjects: [mathematics_subject]
    )
  end

  def when_i_filter_by_courses_that_sponsor_visa
    check 'Only show courses with visa sponsorship', visible: :all
  end

  def and_i_click_apply_filters
    click_link_or_button 'Apply filters', match: :first
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

  def then_i_see_location_suggestions
    expect(page).to have_css('#location-field__listbox', visible: :visible)
    expect(page.find_by_id('location-field__listbox')).to have_content('London, UK')
  end

  def when_i_select_the_first_suggestion
    page.find_by_id('location-field__option--0').click
  end

  def and_i_click_to_search_courses_in_london
    stub_request(
      :get,
      'https://maps.googleapis.com/maps/api/geocode/json?address=London,%20UK&components=country:UK&key=replace_me&language=en'
    )
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Connection' => 'keep-alive',
          'Keep-Alive' => '30',
          'User-Agent' => 'Faraday v2.12.2'
        }
      )
      .to_return(
        status: 200,
        body: file_fixture('google_old_places_api_client/geocode/london.json').read,
        headers: { 'Content-Type' => 'application/json' }
      )

    and_i_click_search
  end

  def then_i_see_only_courses_within_selected_location_within_default_radius
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_content(@london_mathematics_course.name_and_code)

    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
  end

  def and_the_default_radius_is_selected
    expect(page).to have_select('Search radius', selected: '10 miles')
  end

  def and_the_15_miles_radius_is_selected
    expect(page).to have_select('Search radius', selected: '15 miles')
  end

  def and_the_20_miles_radius_is_selected
    expect(page).to have_select('Search radius', selected: '20 miles')
  end

  def and_i_click_search
    click_link_or_button 'Search'
  end

  def when_i_increase_the_radius_to_15_miles
    select '15 miles', from: 'radius'
  end
  alias_method :and_i_increase_the_radius_to_15_miles, :when_i_increase_the_radius_to_15_miles

  def then_i_see_courses_up_to_15_miles_distance
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_content(@london_mathematics_course.name_and_code)
    expect(results).to have_content(@romford_primary_course.name_and_code)
    expect(results).to have_content(@romford_mathematics_course.name_and_code)

    expect(results).to have_no_content(@watford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
  end

  def when_i_increase_the_radius_to_20_miles
    select '20 miles', from: 'radius'
  end

  def then_i_see_courses_up_to_20_miles_distance
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_content(@london_mathematics_course.name_and_code)
    expect(results).to have_content(@romford_primary_course.name_and_code)
    expect(results).to have_content(@romford_mathematics_course.name_and_code)
    expect(results).to have_content(@watford_primary_course.name_and_code)
    expect(results).to have_content(@watford_mathematics_course.name_and_code)
  end

  def and_select_primary_subject
    fill_in 'Subject', with: 'Pri'

    and_i_choose_the_first_subject_suggestion
  end

  def and_i_choose_the_first_subject_suggestion
    page.find('input[name="subject_name"]').native.send_keys(:return)
  end

  def then_i_see_only_courses_within_selected_location_and_primary_subject_within_default_radius
    expect(results).to have_content(@london_primary_course.name_and_code)
    expect(results).to have_no_content(@london_mathematics_course.name_and_code)
    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
  end

  def and_i_click_search
    click_link_or_button 'Search'
  end

  def when_i_search_for_math
    fill_in 'Subject', with: 'Mat'
  end

  def then_i_see_only_mathematics_courses
    expect(results).to have_content(@london_mathematics_course.name_and_code)
    expect(results).to have_content(@romford_mathematics_course.name_and_code)
    expect(results).to have_content(@watford_mathematics_course.name_and_code)

    expect(results).to have_no_content(@london_primary_course.name_and_code)
    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
  end

  def then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
    expect(results).to have_content(@london_mathematics_course.name_and_code)

    expect(results).to have_no_content(@romford_mathematics_course.name_and_code)
    expect(results).to have_no_content(@watford_mathematics_course.name_and_code)
    expect(results).to have_no_content(@london_primary_course.name_and_code)
    expect(results).to have_no_content(@romford_primary_course.name_and_code)
    expect(results).to have_no_content(@watford_primary_course.name_and_code)
  end

  def results
    page.first('.app-search-results')
  end
end
