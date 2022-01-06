# frozen_string_literal: true

require "rails_helper"

feature "Managing a provider's locations" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    when_i_visit_a_provider_locations_page
  end

  scenario "i can view a provider's locations" do
    then_i_should_see_a_list_of_locations
  end

  scenario "i can add a new location" do
    and_i_click_on_the_add_location_link
    then_should_be_on_the_create_page_for_the_location
    when_i_add_the_location_details
    and_i_submit_for(provider_location_create_page)
    then_i_should_see_a_success_message_for(:created)
    and_the_new_location_should_show_in_the_list
  end

  scenario "i can edit a provider's locations" do
    and_i_click_on_the_edit_link_for_a_location
    then_should_be_on_the_edit_page_for_the_location
    when_i_edit_the_location_details
    and_i_submit_for(provider_location_edit_page)
    then_i_should_see_a_success_message_for(:updated)
    and_the_location_details_are_updated
  end

  scenario "i cannot update with invalid data" do
    and_i_click_on_the_edit_link_for_a_location
    and_i_submit_with_invalid_data
    then_i_should_see_a_an_error_message
  end

  scenario "i can delete a provider's location" do
    and_i_click_on_the_edit_link_for_a_location
    and_i_choose_to_delete_the_location
    then_the_location_should_be_deleted
  end

  def when_i_visit_a_provider_locations_page
    provider_locations_index_page.load(provider_id: provider.id)
  end

  def then_i_should_see_a_list_of_locations
    expect(provider_locations_index_page.locations.size).to eq(1)

    expect(provider_locations_index_page.locations.first.name).to have_text(site.location_name)
    expect(provider_locations_index_page.locations.first.code).to have_text(site.code)
    expect(provider_locations_index_page.locations.first.urn).to have_text(site.urn)
  end

  def and_i_click_on_the_add_location_link
    provider_locations_index_page.add_location.click
  end

  def then_should_be_on_the_create_page_for_the_location
    expect(provider_location_create_page).to be_displayed
  end

  def when_i_add_the_location_details
    provider_location_create_page.location_form.location_name.set("Acre woods")
    provider_location_create_page.location_form.urn.set("12345")
    provider_location_create_page.location_form.building_and_street.set("100 Acre Woods")
    provider_location_create_page.location_form.postcode.set("BN1 1AA")
  end

  def and_the_new_location_should_show_in_the_list
    expect(provider_locations_index_page.locations.first.name).to have_text("Acre woods")
  end

  def and_i_click_on_the_edit_link_for_a_location
    provider_locations_index_page.locations.first.edit_link.click
  end

  def then_should_be_on_the_edit_page_for_the_location
    expect(provider_location_edit_page).to be_displayed
  end

  def when_i_edit_the_location_details
    provider_location_edit_page.location_form.location_name.set("Updated location name")
  end

  def and_i_submit_for(page_object)
    page_object.submit.click
  end

  def then_i_should_see_a_success_message_for(flash_key)
    expect(page).to have_content(I18n.t("support.flash.#{flash_key}", resource: "Location"))
  end

  def and_the_location_details_are_updated
    site.reload

    expect(site.location_name).to eq("Updated location name")
  end

  def and_i_submit_with_invalid_data
    provider_location_edit_page.location_form.location_name.set(nil)
    and_i_submit_for(provider_location_edit_page)
  end

  def then_i_should_see_a_an_error_message
    expect(provider_location_edit_page.errors.size).to eq(1)
  end

  def and_i_choose_to_delete_the_location
    provider_location_edit_page.delete_record.click
  end

  def then_the_location_should_be_deleted
    expect(provider_locations_index_page.locations.size).to eq(0)
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def site
    @site ||= provider.sites.first
  end
end
