# frozen_string_literal: true

require "rails_helper"

feature "Providers show" do
  context "user with single provider" do
    let(:user) { create(:user, :with_provider) }

    scenario "view page as Anne" do
      given_i_am_authenticated(user: user)
      when_i_visit_the_publish_providers_show_page
      i_should_see_the_organisations_link
      i_should_see_the_locations_link
      i_should_see_the_courses_link
      i_should_see_the_users_partial
      i_should_not_see_the_accredited_courses_link
      i_should_not_see_the_allocations_link
    end
  end

  context "user with accredited body" do
    let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }
    let(:accredited_body) { create(:provider, :accredited_body, recruitment_cycle: current_recruitment_cycle) }
    let(:user) { create(:user, providers: [accredited_body]) }

    scenario "view page as Susy" do
      given_i_am_authenticated(user: user)
      when_i_visit_the_publish_providers_show_page
      i_should_see_the_organisations_link
      i_should_see_the_locations_link
      i_should_see_the_courses_link
      i_should_see_the_users_partial
      i_should_see_the_accredited_courses_link
      i_should_see_the_allocations_link
    end
  end

  def when_i_visit_the_publish_providers_show_page
    publish_providers_show_page.load
  end

  def i_should_see_the_organisations_link
    expect(publish_providers_show_page).to have_about_your_organisation
  end

  def i_should_see_the_locations_link
    expect(publish_providers_show_page).to have_locations
  end

  def i_should_see_the_courses_link
    expect(publish_providers_show_page).to have_courses
  end

  def i_should_see_the_users_partial
    expect(publish_providers_show_page).to have_users
  end

  def i_should_see_the_accredited_courses_link
    expect(publish_providers_show_page).to have_accredited_courses
  end

  def i_should_see_the_allocations_link
    expect(publish_providers_show_page).to have_allocations
  end

  def i_should_not_see_the_accredited_courses_link
    expect(publish_providers_show_page).not_to have_accredited_courses
  end

  def i_should_not_see_the_allocations_link
    expect(publish_providers_show_page).not_to have_allocations
  end
end