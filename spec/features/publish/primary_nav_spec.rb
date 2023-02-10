# frozen_string_literal: true

require 'rails_helper'

feature 'Primary nav', { can_edit_current_and_next_cycles: false } do
  scenario 'view page as Anne - user with single provider' do
    and_i_am_authenticated_as_a_provider_user
    when_i_visit_the_courses_index_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_locations_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_not_see_the_accredited_bodies_link
    and_i_should_not_see_the_accredited_bodies_link
  end

  scenario 'view page as Susy - user with accredited body' do
    given_i_am_authenticated_as_an_accredited_body_user
    when_i_visit_the_courses_index_page
    then_i_should_see_the_organisation_details_link
    and_i_should_see_the_locations_link
    and_i_should_see_the_courses_link
    and_i_should_see_the_users_link
    and_i_should_see_the_accredited_bodies_link
  end

  def and_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_accredited_body_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
  end

  def when_i_visit_the_courses_index_page
    publish_provider_courses_index_page
  end

  def then_i_should_see_the_organisation_details_link
    expect(publish_primary_nav_page).to have_organisation_details
  end

  def and_i_should_see_the_locations_link
    expect(publish_primary_nav_page).to have_locations
  end

  def and_i_should_see_the_courses_link
    expect(publish_primary_nav_page).to have_courses
  end

  def and_i_should_see_the_users_link
    expect(publish_primary_nav_page).to have_users
  end

  def and_i_should_see_the_accredited_bodies_link
    expect(publish_primary_nav_page).to have_accredited_bodies
  end

  def and_i_should_not_see_the_accredited_bodies_link
    expect(publish_primary_nav_page).not_to have_accredited_bodies
  end

  def and_i_should_not_see_the_accredited_bodies_link
    expect(page).not_to have_text 'Change organisation'
  end
end
