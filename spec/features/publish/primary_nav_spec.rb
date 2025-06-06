# frozen_string_literal: true

require "rails_helper"

feature "Primary nav" do
  scenario "view page as Anne - user with single provider" do
    and_i_am_authenticated_as_a_provider_user
    when_i_visit_the_courses_index_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_schools_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_not_see_the_training_partners_link
  end

  scenario "view page as Susy - user with accredited provider" do
    given_i_am_authenticated_as_an_accredited_provider_user
    when_i_visit_the_courses_index_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_schools_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_see_the_training_partners_link
  end

  def and_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_accredited_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_provider)]))
  end

  def when_i_visit_the_courses_index_page
    publish_provider_courses_index_page
  end

  def then_i_should_see_the_organisation_details_link
    expect(publish_primary_nav_page).to have_organisation_details
  end

  def and_i_should_see_the_schools_link
    expect(publish_primary_nav_page).to have_schools
  end

  def and_i_should_see_the_courses_link
    expect(publish_primary_nav_page).to have_courses
  end

  def and_i_should_see_the_users_link
    expect(publish_primary_nav_page).to have_users
  end

  def and_i_should_see_the_training_partners_link
    expect(publish_primary_nav_page).to have_training_partners
  end

  def and_i_should_not_see_the_training_partners_link
    expect(publish_primary_nav_page).not_to have_training_partners
  end

  def and_i_should_not_see_the_training_partners_link
    expect(page).to have_no_text "Change organisation"
  end
end
