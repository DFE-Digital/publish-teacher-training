require "rails_helper"

RSpec.describe "View pages" do
  scenario "As a Candidate, I can visit my saved courses" do
    given_candidate_accounts_is_active
    when_i_visit_the_find_homepage
    then_i_see_a_login_button

    when_i_click_login
    then_i_see_that_i_am_logged_in

    then_i_can_see_the_primary_navigation_links
    then_i_click_the_saved_courses_link
  end

  scenario "As a Candidate, I cant visit my saved courses when not logged in" do
    given_candidate_accounts_is_active
    when_i_visit_the_find_homepage
    then_i_cant_see_the_primary_navigation_links
    then_i_cant_visit_saved_courses_page_without_logging_in
  end

  def given_candidate_accounts_is_active
    FeatureFlag.activate(:candidate_accounts)
  end

  def when_i_visit_the_find_homepage
    visit "/"
  end

  def then_i_see_a_login_button
    expect(page).to have_button("Login")
  end

  def when_i_click_login
    click_link_or_button "Login"
  end

  def then_i_see_that_i_am_logged_in
    expect(page).to have_content("You're logged in!")
  end

  def then_i_can_see_the_primary_navigation_links
    within ".govuk-service-navigation__container" do
      expect(page).to have_link("Courses", href: find_root_path)
      expect(page).to have_link("Saved courses", href: find_candidate_saved_courses_path)
    end
  end

  def then_i_cant_see_the_primary_navigation_links
    within ".govuk-service-navigation__container" do
      expect(page).not_to have_link("Courses", href: find_root_path)
      expect(page).not_to have_link("Saved courses", href: find_candidate_saved_courses_path)
    end
  end

  def then_i_click_the_saved_courses_link
    within ".govuk-service-navigation__container" do
      click_link("Saved courses")
    end

    expect(page).to have_current_path(find_candidate_saved_courses_path)
  end

  def then_i_cant_visit_saved_courses_page_without_logging_in
    visit find_candidate_saved_courses_path

    expect(page).to have_current_path(new_find_sessions_path)
  end
end
