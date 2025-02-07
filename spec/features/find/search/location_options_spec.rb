# frozen_string_literal: true

require 'rails_helper'

feature 'Searching by location' do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    stub_geocoder_lookup

    given_i_visit_the_start_page
    and_i_select_the_location_radio_button
  end

  scenario 'attempting to search without query' do
    and_i_click_continue
    then_i_should_see_a_missing_location_validation_error
  end

  scenario 'when searchng a small area persists the correct location options in the url' do
    when_i_enter_a_1d_location

    and_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_correct_age_group_form_page_url_and_query_params_are_present_for_small_area

    when_i_click_back
    then_i_should_see_the_start_page
    and_the_location_radio_button_is_selected
  end

  scenario 'when searchng a large area persists the correct location options in the url' do
    when_i_enter_a_2d_location
    and_i_click_continue
    then_i_should_see_the_age_groups_form
    and_the_correct_age_group_form_page_url_and_query_params_are_present_for_large_area

    when_i_click_back
    then_i_should_see_the_start_page
    and_the_location_radio_button_is_selected
  end

  scenario 'searching for a location with no results' do
    when_i_enter_an_invalid_location_with_some_options
    and_i_provide_my_visa_status
    then_should_see_the_no_results_text
  end

  private

  def given_i_visit_the_start_page
    find_courses_by_location_or_training_provider_page.load
  end

  def and_i_select_the_location_radio_button
    find_courses_by_location_or_training_provider_page.by_city_town_or_postcode_radio.choose
  end

  def and_i_click_continue
    find_courses_by_location_or_training_provider_page.continue.click
  end

  def then_i_should_see_a_missing_location_validation_error
    expect(page).to have_content('Enter a city, town or postcode')
  end

  def when_i_enter_a_1d_location
    find_courses_by_location_or_training_provider_page.location.set('Station Rise')
  end

  def when_i_enter_a_2d_location
    find_courses_by_location_or_training_provider_page.location.set('Cornwall')
  end

  def then_i_should_see_the_age_groups_form
    expect(page).to have_content(I18n.t('find.age_groups.title'))
  end

  def and_the_correct_age_group_form_page_url_and_query_params_are_present_for_large_area
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/age-groups')
      expect(uri.query).to eq('c=England&l=1&latitude=50.5036299&loc=Cornwall%2C+UK&longitude=-4.6524982&lq=Cornwall&radius=50&sortby=distance')
    end
  end

  def and_the_correct_age_group_form_page_url_and_query_params_are_present_for_small_area
    URI(current_url).then do |uri|
      expect(uri.path).to eq('/age-groups')
      expect(uri.query).to eq('c=England&l=1&latitude=53.83365879999999&loc=Station+Rise%2C+Ricall%2C+York+YO19+2C%2C+UK&longitude=-1.0564076&lq=Station+Rise&radius=10&sortby=distance')
    end
  end

  def then_i_should_see_the_start_page
    expect(find_courses_by_location_or_training_provider_page).to be_displayed
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def and_the_location_radio_button_is_selected
    expect(find_courses_by_location_or_training_provider_page.by_city_town_or_postcode_radio).to be_checked
  end

  def when_i_enter_an_invalid_location_with_some_options
    find_courses_by_location_or_training_provider_page.location.set('invalid location')
    find_courses_by_location_or_training_provider_page.continue.click
    choose 'Further education'
    click_link_or_button 'Continue'
  end

  def and_i_provide_my_visa_status
    choose 'Yes'
    click_link_or_button 'Find courses'
  end

  def then_should_see_the_no_results_text
    expect(page).to have_content('No courses found')
  end
end
