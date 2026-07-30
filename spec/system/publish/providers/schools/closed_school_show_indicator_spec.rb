# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Provider school show page closed indicator" do
  scenario "flags a school whose GIAS record has closed" do
    given_i_am_signed_in_viewing_a_school_backed_by(create(:gias_school, :closed, urn: "654321"))
    when_i_visit_the_school_show_page
    then_i_see_it_flagged_as_closed
  end

  scenario "does not flag an available school" do
    given_i_am_signed_in_viewing_a_school_backed_by(create(:gias_school, :open, urn: "123456"))
    when_i_visit_the_school_show_page
    then_i_do_not_see_it_flagged_as_closed
  end

  def given_i_am_signed_in_viewing_a_school_backed_by(gias_school)
    @provider = create(:provider)
    @school = create(:provider_school, provider: @provider, gias_school:)

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end

  def when_i_visit_the_school_show_page
    visit publish_provider_recruitment_cycle_school_path(@provider.provider_code, @provider.recruitment_cycle_year, @school.uuid)
  end

  def then_i_see_it_flagged_as_closed
    expect(page).to have_content("Closed")
  end

  def then_i_do_not_see_it_flagged_as_closed
    expect(page).to have_no_content("Closed")
  end
end
