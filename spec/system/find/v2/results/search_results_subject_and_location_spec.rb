# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2 results - enabled', :js, service: :find do
  include FiltersFeatureSpecsHelper

  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    FeatureFlag.activate(:prefiltering_find_redesign)
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:memory_store))

    given_courses_exist_in_various_locations
    when_i_visit_the_results_page
  end

  scenario 'when I filter by location' do
    when_i_start_typing_an_invalid_location
    then_i_see_no_autocomplete_suggestions

    when_i_start_typing_london_location
    then_i_see_location_suggestions
    and_the_location_suggestions_for_london_is_cached

    when_i_select_the_first_suggestion
    and_i_click_to_search_courses_in_london
    then_i_see_only_courses_within_selected_location_within_default_radius
    and_the_default_radius_is_selected
    and_the_location_search_for_coordinates_is_cached

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

  scenario 'when I search by provider' do
    when_i_search_for_a_provider
    and_i_choose_the_first_provider_suggestion
    and_i_click_search
    then_i_see_only_courses_from_that_provider
    and_the_provider_field_is_visible
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

  context 'searching from the homepage' do
    before { when_i_visit_the_homepage }

    scenario 'when I search from the homepage' do
      when_i_start_typing_an_invalid_location
      then_i_see_no_autocomplete_suggestions

      when_i_start_typing_london_location
      then_i_see_location_suggestions
      and_the_location_suggestions_for_london_is_cached

      when_i_select_the_first_suggestion
      and_i_click_to_search_courses_in_london
      then_i_see_only_courses_within_selected_location_within_default_radius
      and_the_default_radius_is_selected
      and_the_location_search_for_coordinates_is_cached

      and_i_am_on_the_results_page_with_london_location_as_parameter
    end

    scenario 'when I search all filters from the homepage' do
      when_i_search_for_math
      and_i_choose_the_first_subject_suggestion

      when_i_start_typing_london_location
      then_i_see_location_suggestions

      when_i_select_the_first_suggestion
      and_i_check_visa_sponsorship_filter_in_the_homepage
      and_i_click_to_search_courses_in_london

      then_i_see_mathematics_courses_in_15_miles_from_london_that_sponsors_visa
      and_i_am_on_the_results_page_with_mathematics_subject_and_london_location_and_sponsor_visa_as_parameter
    end
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
      provider: create(:provider, provider_name: 'First university'),
      site_statuses: [create(:site_status, :findable, site: create(:site, latitude: london.latitude, longitude: london.longitude))],
      subjects: [primary_subject]
    )

    @romford_primary_course = create(
      :course,
      :primary,
      name: 'Primary - Romford',
      provider: create(:provider, provider_name: 'Second university'),
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
    visit find_results_path
  end

  def when_i_start_typing_an_invalid_location
    fill_in 'City, town or postcode', with: 'NonExistentCity'
  end

  def then_i_see_no_autocomplete_suggestions
    expect(page).to have_css('#location-field__listbox', visible: :hidden)
  end

  def and_the_location_suggestions_for_london_is_cached
    expect(Rails.cache.read('geolocation:suggestions:lon')).to eq(
      [
        {
          name: 'London, UK',
          place_id: 'ChIJdd4hrwug2EcRmSrV3Vo6llI',
          types: %w[locality political]
        }
      ]
    )
  end

  def and_the_location_search_for_coordinates_is_cached
    expect(Rails.cache.read('geolocation:query:london-uk')).to eq(
      {
        formatted_address: 'London, UK',
        latitude: 51.5072178,
        longitude: -0.1275862,
        country: 'England',
        types: %w[locality political]
      }
    )
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
    ).to_return(status: 200, body: file_fixture('google_old_places_api_client/autocomplete/london.json'), headers: { 'Content-Type' => 'application/json' })

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

  def and_i_am_on_the_results_page_with_london_location_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(subject_name: '', subject_code: '', location: 'London, UK')
  end

  def and_i_am_on_the_results_page_with_mathematics_subject_and_london_location_and_sponsor_visa_as_parameter
    and_i_am_on_the_results_page

    expect(search_params).to eq(
      subject_name: 'Mathematics',
      subject_code: 'G1',
      location: 'London, UK',
      can_sponsor_visa: 'true'
    )
  end

  def when_i_visit_the_homepage
    visit find_root_path
  end

  def and_i_check_visa_sponsorship_filter_in_the_homepage
    and_i_am_on_the_homepage
    check 'Only show courses that offer visa sponsorship', visible: :all
  end

  def and_i_am_on_the_homepage
    expect(page).to have_current_path(find_root_path)
  end

  def and_i_am_on_the_results_page
    expect(page).to have_current_path(find_results_path, ignore_query: true)
  end

  def when_i_search_for_a_provider
    page.find(
      'summary.govuk-details__summary',
      text: 'Search by training provider'
    ).click

    fill_in 'Enter a provider name', with: 'uni'
  end

  def and_i_choose_the_first_provider_suggestion
    page.find_by_id('provider-code-field__option--0').click
  end

  def then_i_see_only_courses_from_that_provider
    expect(results).to have_content('First university')

    providers = Provider.where.not(provider_name: 'First university')

    providers.each do |provider|
      expect(results).to have_no_content(provider.provider_name)
    end
  end

  def and_the_provider_field_is_visible
    expect(page).to have_css('details.govuk-details[open]')
  end

  private

  def results
    page.first('.app-search-results')
  end

  def search_params
    query_params(URI(page.current_url)).symbolize_keys.except(:utm_source, :utm_medium)
  end
end
