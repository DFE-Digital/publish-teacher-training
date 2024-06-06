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

  def given_i_am_authenticated_as_a_non_admin
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def given_i_am_authenticated_as_an_admin
    given_i_am_authenticated(user: create(:user, :admin))
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
