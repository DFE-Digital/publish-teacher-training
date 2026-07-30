# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support provider school show page closed indicator" do
  scenario "flags a school whose GIAS record has closed" do
    @provider = create(:provider)
    school = create(:provider_school, provider: @provider, gias_school: create(:gias_school, :closed))

    given_i_am_authenticated(user: create(:user, :admin))

    visit support_recruitment_cycle_provider_school_path(
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      provider_id: @provider.id,
      uuid: school.uuid,
    )

    expect(page).to have_content("Closed")
  end
end
