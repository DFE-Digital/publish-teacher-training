# frozen_string_literal: true

require "rails_helper"

feature "Viewing a providers courses" do
  scenario "i can a provider's locations" do
    given_i_am_authenticated(user: create(:user, :admin))
    when_i_visit_a_provider_locations_page
    then_i_should_see_a_list_of_locations
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

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def site
    @site ||= provider.sites.first
  end
end
