# frozen_string_literal: true

require "rails_helper"

feature "Providers show" do
  scenario "view page as Anne - user with single provider" do
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_a_provider_user
    when_i_visit_the_publish_providers_show_page
    i_should_see_the_organisation_details_link
    i_should_see_the_locations_link
    i_should_see_the_courses_link
    i_should_see_the_users_link
    i_should_not_see_the_training_partners_link
    i_should_not_see_the_allocations_link
    i_should_not_see_the_change_organisation_link
  end

  scenario "view page as Susy - user with accredited body" do
    given_the_new_publish_flow_feature_flag_is_enabled
    given_i_am_authenticated_as_an_accredited_body_user
    when_i_visit_the_publish_providers_show_page
    i_should_see_the_organisation_details_link
    i_should_see_the_locations_link
    i_should_see_the_courses_link
    i_should_see_the_users_link
    i_should_see_the_training_partners_link
    i_should_not_see_the_allocations_link
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    allow(Settings.features).to receive(:new_publish_navigation).and_return(true)
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

  def i_should_see_the_organisation_details_link
    expect(publish_providers_show_page).to have_nav_organisation_details
  end

  def i_should_see_the_locations_link
    expect(publish_providers_show_page).to have_nav_locations
  end

  def i_should_see_the_courses_link
    expect(publish_providers_show_page).to have_nav_courses
  end

  def i_should_see_the_users_link
    expect(publish_providers_show_page).to have_nav_users
  end

  def i_should_see_the_training_partners_link
    expect(publish_providers_show_page).to have_nav_training_partners
  end

  def i_should_not_see_the_training_partners_link
    expect(publish_providers_show_page).not_to have_nav_training_partners
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
