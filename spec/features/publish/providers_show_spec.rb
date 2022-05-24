# frozen_string_literal: true

require "rails_helper"

feature "Providers show" do
  scenario "view page as Anne - user with single provider" do
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_providers_show_page
    i_should_see_the_organisations_link
    i_should_see_the_locations_link
    i_should_see_the_courses_link
    i_should_see_the_users_partial
    i_should_not_see_the_accredited_courses_link
    i_should_not_see_the_allocations_link
    i_should_not_see_the_change_organisation_link
  end

  scenario "view page as Susy - user with accredited body" do
    given_the_new_publish_flow_feature_flag_is_enabled
    given_i_am_authenticated_as_an_accredited_body_user
    when_i_visit_the_publish_providers_show_page
    i_should_see_the_organisations_link
    i_should_see_the_locations_link
    i_should_see_the_courses_link
    i_should_see_the_users_partial
    i_should_see_the_accredited_courses_link
    i_should_see_the_allocations_link
  end

  def and_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_accredited_body_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
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

  def i_should_not_see_the_change_organisation_link
    expect(page).not_to have_text "Change organisation"
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    allow(Settings.features).to receive(:new_publish_navigation).and_return(true)
  end
end
