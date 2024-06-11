# frozen_string_literal: true

require 'rails_helper'

feature 'Blazer SQL tool', { can_edit_current_and_next_cycles: false } do
  scenario 'i can access blazer as an admin' do
    given_i_am_authenticated_as_an_admin
    when_i_visit_the_blazer_page
    then_i_am_taken_to_the_blazer_page
  end

  scenario 'i cannot access blazer as a non admin' do
    given_i_am_authenticated_as_a_non_admin
    when_i_visit_the_blazer_page
    then_i_see_page_not_found
  end

  context 'when the environment variables are set' do
    around do |example|
      original_env_var = ENV.fetch('BLAZER_ALLOWED_IDS', nil)
      ENV['BLAZER_ALLOWED_IDS'] = '1,3,4'
      example.run
    ensure
      ENV['BLAZER_ALLOWED_IDS'] = original_env_var
    end

    scenario 'when the user is authorised to access blazer' do
      given_i_am_authenticated_as_an_admin_who_is_authorised_to_access_blazer
      when_i_visit_the_blazer_page
      then_i_am_taken_to_the_blazer_page
    end

    scenario 'when the user is not authorised to access blazer' do
      given_i_am_authenticated_as_an_admin_who_is_not_authorised_to_access_blazer
      when_i_visit_the_blazer_page
      then_i_see_page_not_found
    end

    scenario 'when the user is not an admin but is authorised to access blazer' do # This tests for malicious intent
      given_i_am_authenticated_as_a_non_admin_who_is_authorised_to_access_blazer
      when_i_visit_the_blazer_page
      then_i_see_page_not_found
    end
  end

  def given_i_am_authenticated_as_a_non_admin
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_admin
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def given_i_am_authenticated_as_an_admin_who_is_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :admin, id: 1))
  end

  def given_i_am_authenticated_as_an_admin_who_is_not_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :admin, id: 2))
  end

  def given_i_am_authenticated_as_a_non_admin_who_is_authorised_to_access_blazer
    given_i_am_authenticated(user: create(:user, :with_provider, id: 4))
  end

  def when_i_visit_the_blazer_page
    visit(blazer_path)
  end

  def then_i_am_taken_to_the_blazer_page
    expect(page).to have_current_path blazer_path
  end

  def then_i_should_be_redirected_to_the_courses_index_page
    expect(publish_provider_courses_index_page).to be_displayed
  end

  def then_i_see_page_not_found
    expect(page.status_code).to eq(404)
  end
end
