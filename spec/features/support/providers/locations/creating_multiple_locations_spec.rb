# frozen_string_literal: true

require 'rails_helper'

feature 'Multiple locations' do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
  end

  scenario 'submitting an empty form' do
    and_the_multiple_locations_feature_flag_is_active
    when_i_visit_a_provider_locations_page
    then_i_click_add_multiple_locations

    given_i_submit_an_empty_form
    then_i_should_see_the_validation_error_message
  end

  scenario 'submitting an form with two locations' do
    and_the_multiple_locations_feature_flag_is_active
    when_i_visit_the_multiple_locations_new_page
    and_i_submit_the_form_with_two_locations
    and_i_see_the_text_1_of_2
    then_i_should_see_that_the_text_field_has_been_prepopulated('Name', 'A')

    given_i_submit_a_valid_form
    and_i_see_the_text_2_of_2
    and_i_see_that_the_text_field_has_been_prepopulated('Name', 'B')
    and_i_submit_a_valid_form
    then_i_should_be_redirected_to_the_provider_location_page
  end

  scenario 'feature flag off' do
    when_i_visit_a_provider_locations_page
    then_i_should_not_see_the_add_multiple_locations_link
  end

  def then_i_should_be_redirected_to_the_provider_location_page
    expect(page).to have_current_path support_recruitment_cycle_provider_locations_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def then_i_should_see_that_the_text_field_has_been_prepopulated(name, text)
    expect(page).to have_field(name, with: text)
  end

  def given_i_submit_a_valid_form
    fill_in 'Address line 1', with: '1 amazing street'
    fill_in 'Postcode', with: 'BN1 1AA'
    click_continue
  end

  def and_i_see_the_text_1_of_2
    expect(page).to have_text 'Add location (1 of 2)'
  end

  def and_i_see_the_text_2_of_2
    expect(page).to have_text 'Add location (2 of 2)'
  end

  def and_i_submit_the_form_with_two_locations
    fill_in 'Location details', with: "A\nB"
    click_continue
  end

  def when_i_visit_the_multiple_locations_new_page
    visit new_support_recruitment_cycle_provider_locations_multiple_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def when_i_visit_a_provider_locations_page
    visit support_recruitment_cycle_provider_locations_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def and_the_multiple_locations_feature_flag_is_active
    allow(Settings.features).to receive(:add_multiple_locations).and_return(true)
  end

  def then_i_click_add_multiple_locations
    click_link 'Add multiple locations'
  end

  def then_i_should_not_see_the_add_multiple_locations_link
    expect(page).not_to have_link('Add multiple locations')
  end

  def given_i_submit_an_empty_form
    click_button 'Continue'
  end

  def then_i_should_see_the_validation_error_message
    expect(page).to have_text('Enter location details')
  end

  alias_method :and_i_submit_a_valid_form, :given_i_submit_a_valid_form
  alias_method :and_i_see_that_the_text_field_has_been_prepopulated, :then_i_should_see_that_the_text_field_has_been_prepopulated
  alias_method :click_continue, :given_i_submit_an_empty_form
end
