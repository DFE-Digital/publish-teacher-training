# frozen_string_literal: true

require "rails_helper"

feature "Managing a provider's locations" do
  before do
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_locations_page
  end

  scenario "i can view a provider's locations" do
    then_i_should_see_a_list_of_locations
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])]),
    )
  end

  def when_i_visit_the_locations_page
    publish_provider_locations_index_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def then_i_should_see_a_list_of_locations
    expect(publish_provider_locations_index_page.locations.size).to eq(1)

    expect(publish_provider_locations_index_page.locations.first.name).to have_text(site.location_name)
    expect(publish_provider_locations_index_page.locations.first.code).to have_text(site.code)
    expect(publish_provider_locations_index_page.locations.first.urn).to have_text(site.urn)
  end

  def provider
    @current_user.providers.first
  end

  def site
    @site ||= provider.sites.first
  end
end
