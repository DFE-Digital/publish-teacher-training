# frozen_string_literal: true

require "rails_helper"

feature "Primary nav" do
  scenario "view page as Anne - user with single provider" do
    given_the_new_publish_flow_feature_flag_is_enabled
    and_i_am_authenticated_as_a_provider_user
    when_i_visit_the_providers_show_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_locations_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_not_see_the_training_partners_link
    and_i_should_not_see_the_training_partners_link
  end

  scenario "view page as Susy - user with accredited body" do
    given_the_new_publish_flow_feature_flag_is_enabled
    given_i_am_authenticated_as_an_accredited_body_user
    when_i_visit_the_providers_show_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_locations_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_see_the_training_partners_link
  end

  def given_the_new_publish_flow_feature_flag_is_enabled
    enable_features(:new_publish_navigation)
  end

  def and_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_accredited_body_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
  end

  def when_i_visit_the_providers_show_page
    publish_providers_show_page.load
  end

  def then_i_should_see_the_organisation_details_link
    expect(primary_nav).to have_organisation_details
  end

  def and_i_should_see_the_locations_link
    expect(primary_nav).to have_locations
  end

  def and_i_should_see_the_courses_link
    expect(primary_nav).to have_courses
  end

  def and_i_should_see_the_users_link
    expect(primary_nav).to have_users
  end

  def and_i_should_see_the_training_partners_link
    expect(primary_nav).to have_training_partners
  end

  def and_i_should_not_see_the_training_partners_link
    expect(primary_nav).not_to have_training_partners
  end

  def and_i_should_not_see_the_training_partners_link
    expect(page).not_to have_text "Change organisation"
  end
end
