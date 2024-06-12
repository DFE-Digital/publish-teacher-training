# frozen_string_literal: true

require 'rails_helper'

feature 'Blazer SQL tool', { can_edit_current_and_next_cycles: false } do
  scenario 'i cannot access blazer as an admin who does not have blazer access' do
    given_i_am_authenticated_as_an_admin
    when_i_visit_the_blazer_page
    then_i_see_page_not_found
  end

  scenario 'i cannot access blazer as a non admin who does not have blazer access' do
    given_i_am_authenticated_as_a_non_admin
    when_i_visit_the_blazer_page
    then_i_see_page_not_found
  end

  scenario 'I cannot access blazer as a non admin with blazer access' do
    given_i_am_authenticated_as_a_non_admin_who_is_authorised_to_access_blazer
    when_i_visit_the_blazer_page
    then_i_see_page_not_found
  end

  scenario 'i can access blazer as an admin who has blazer access' do
    given_i_am_authenticated_as_an_admin_who_is_authorised_to_access_blazer
    when_i_visit_the_blazer_page
    then_i_am_taken_to_the_blazer_page
  end

  def given_i_am_authenticated_as_a_non_admin
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_admin
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def given_i_am_authenticated_as_an_admin_who_is_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :admin, blazer_access: true))
  end

  def given_i_am_authenticated_as_an_admin_who_is_not_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :admin, id: 2))
  end

  def given_i_am_authenticated_as_a_non_admin_who_is_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :with_provider, id: 4, blazer_access: true))
  end

  def when_i_visit_the_blazer_page
    visit(blazer_path)
  end

  def then_i_am_taken_to_the_blazer_page
    expect(page).to have_current_path blazer_path
    expect(page.status_code).to eq(200)
  end

  def then_i_should_be_redirected_to_the_courses_index_page
    expect(publish_provider_courses_index_page).to be_displayed
  end

  def then_i_see_page_not_found
    expect(page.status_code).to eq(404)
  end
end
