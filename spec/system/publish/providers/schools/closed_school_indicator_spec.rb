# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Provider schools index closed indicator" do
  scenario "a school whose GIAS record has closed is flagged" do
    given_i_am_signed_in_with_an_open_and_a_closed_school
    when_i_visit_the_schools_index
    then_the_closed_school_is_tagged_closed
    and_the_open_school_is_not_tagged_closed
  end

  def given_i_am_signed_in_with_an_open_and_a_closed_school
    closed_gias_school = create(:gias_school, :closed, urn: "654321")
    open_gias_school = create(:gias_school, :open, urn: "123456")
    @provider = create(
      :provider,
      sites: [
        build(:site, location_name: "Millbrook School", urn: closed_gias_school.urn),
        build(:site, location_name: "Riverside School", urn: open_gias_school.urn),
      ],
    )

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end

  def when_i_visit_the_schools_index
    visit publish_provider_recruitment_cycle_schools_path(@provider.provider_code, @provider.recruitment_cycle_year)
  end

  def then_the_closed_school_is_tagged_closed
    within(page.find(".school-row", text: "Millbrook School")) do
      expect(page).to have_content("Closed")
    end
  end

  def and_the_open_school_is_not_tagged_closed
    within(page.find(".school-row", text: "Riverside School")) do
      expect(page).to have_no_content("Closed")
    end
  end
end
