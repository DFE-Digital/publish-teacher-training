# frozen_string_literal: true

require "rails_helper"

feature "Managing a provider's locations", { can_edit_current_and_next_cycles: false } do
  scenario "i can view and update a provider's locations" do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_locations_page
    then_i_should_see_a_list_of_locations

    when_i_click_add_a_location
    then_i_can_add_a_location
    when_i_click_on_a_location
    then_i_can_update_its_details
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])]),
    )
  end

  def when_i_visit_the_locations_page
    publish_locations_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_should_see_a_list_of_locations
    expect(publish_locations_index_page.locations.size).to eq(1)

    expect(publish_locations_index_page.locations.first.name).to have_text(site.location_name)
    expect(publish_locations_index_page.locations.first.code).to have_text(site.code)
    expect(publish_locations_index_page.locations.first.urn).to have_text(site.urn)
  end

  def when_i_click_add_a_location
    publish_locations_index_page.add_location.click
  end

  def then_i_can_add_a_location
    expect(page).to have_current_path publish_location_new_page.url(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )

    publish_location_new_page.name_field.set "Some place"
    publish_location_new_page.address1_field.set "123 Test Street"
    publish_location_new_page.postcode_field.set "KT8 9AU"
    publish_location_new_page.submit.click

    expect(publish_locations_index_page.locations.size).to eq(2)
    expect(publish_locations_index_page.locations.last.name).to have_text("Some place")
  end

  def when_i_click_on_a_location
    publish_locations_index_page.locations.last.edit_link.click
  end

  def then_i_can_update_its_details
    expect(page).to have_current_path publish_location_edit_page.url(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      location_id: Site.last.id,
    )

    publish_location_edit_page.name_field.set "Renamed place"
    publish_location_new_page.submit.click
    expect(publish_locations_index_page.locations.size).to eq(2)
    expect(publish_locations_index_page.locations.last.name).to have_text("Renamed place")
  end

private

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end
end
