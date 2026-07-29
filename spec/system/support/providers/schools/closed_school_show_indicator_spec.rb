# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider school show page closed indicator" do
  scenario "flags a school whose GIAS record has closed" do
    closed_gias_school = create(:gias_school, :closed, urn: "654321")
    @provider = create(:provider)
    @site = create(:site, provider: @provider, urn: closed_gias_school.urn)

    given_i_am_authenticated(user: create(:user, :admin))

    visit support_recruitment_cycle_provider_school_path(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_id: @provider.id,
      uuid: @site.uuid,
    )

    expect(page).to have_content("Closed")
  end
end
