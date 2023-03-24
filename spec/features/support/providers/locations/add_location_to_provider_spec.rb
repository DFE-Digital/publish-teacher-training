# frozen_string_literal: true

require 'rails_helper'

feature 'Adding location to provider as an admin', { can_edit_current_and_next_cycles: false, with_publish_constraint: true } do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider
  end

  describe 'Adding location to organisation' do
    scenario 'With valid details' do
      given_i_visit_the_support_provider_locations_index_page
      and_i_click_add_location
      and_i_fill_in_location_name
      and_i_fill_in_address1
      and_i_fill_in_address3
      and_i_fill_in_postcode
      and_i_continue
      then_i_should_be_on_the_check_page
      and_the_location_should_not_be_added_to_the_database

      when_i_click_change_location_name
      and_i_enter_a_new_location_name
      and_i_continue

      then_i_should_see_the_location_name_listed
      and_i_click_add_location_button
      then_i_see_the_success_message
      and_the_location_is_added_to_the_database

      and_i_click_add_location
      and_i_fill_in_location_name
      and_i_fill_in_address1
      and_i_fill_in_address3
      and_i_fill_in_postcode
      and_i_continue
      then_i_should_be_on_the_check_page

      and_i_click_save_and_add_another_location_button
      then_i_see_the_success_message_on_new_page
      and_another_location_is_added_to_the_database
    end

    scenario 'With invalid details' do
      given_i_visit_the_support_provider_locations_new_page
      and_i_continue

      then_it_should_display_the_correct_error_messages
    end
  end

  def then_it_should_display_the_correct_error_messages
    expect(support_provider_location_create_page.error_summary).to have_text('Enter a location name')
    expect(support_provider_location_create_page.error_summary).to have_text('Enter address line 1')
    expect(support_provider_location_create_page.error_summary).to have_text('Enter a town or city')
    expect(support_provider_location_create_page.error_summary).to have_text('Enter a postcode')
  end

  def given_i_visit_the_support_provider_locations_new_page
    support_provider_location_create_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: @provider.id)
  end

  def and_another_location_is_added_to_the_database
    expect(@provider.sites.count).to eq 2
  end

  def and_the_location_is_added_to_the_database
    expect(@provider.sites.count).to eq 1
  end

  def then_i_see_the_success_message_on_new_page
    expect(support_provider_locations_index_page).to have_text('Location added')
  end

  def then_i_see_the_success_message
    expect(support_provider_locations_index_page).to have_text('Location added')
  end

  def and_i_click_save_and_add_another_location_button
    click_button 'Save location and add another'
  end

  def and_i_click_add_location_button
    click_button 'Add location'
  end

  def then_i_should_see_the_location_name_listed
    expect(page).to have_text('New location')
  end

  def and_i_enter_a_new_location_name
    support_provider_location_create_page.location_form.location_name.set('New location')
  end

  def when_i_click_change_location_name
    support_provider_locations_check_page.change_location_name.click
  end

  def and_the_location_should_not_be_added_to_the_database
    expect(@provider.sites.count).to eq 0
  end

  def then_i_should_be_on_the_check_page
    expect(support_provider_locations_check_page).to be_displayed(provider_id: @provider.id)
  end

  def and_i_continue
    support_provider_location_create_page.submit.click
  end

  def and_i_click_add_location
    click_link 'Add location'
  end

  def and_i_fill_in_location_name
    support_provider_location_create_page
      .location_form
      .location_name
      .set('The location')
  end

  def and_i_fill_in_address1
    support_provider_location_create_page
      .location_form
      .building_and_street
      .set('The address')
  end

  def and_i_fill_in_address3
    support_provider_location_create_page
      .location_form
      .town_or_city
      .set('The town')
  end

  def and_i_fill_in_postcode
    support_provider_location_create_page
      .location_form
      .postcode
      .set('TR1 1UN')
  end

  def given_i_visit_the_support_provider_locations_index_page
    support_provider_locations_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: @provider.id)
  end

  def and_there_is_a_provider
    @provider = create(:provider, provider_name: 'School of Cats')
  end

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end
end
