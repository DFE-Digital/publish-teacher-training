require "rails_helper"

RSpec.describe "View pages" do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
  end

  scenario "As a Candidate, I can visit my saved courses" do
    when_i_visit_the_find_homepage

    when_i_click_login
    then_i_see_that_i_am_logged_in

    then_i_can_see_the_primary_navigation_links
    then_i_click_the_saved_courses_link
  end

  scenario "As a Candidate, I cant visit my saved courses when not logged in" do
    when_i_visit_the_find_homepage
    then_i_cant_see_the_primary_navigation_links
    then_i_cant_visit_saved_courses_page_without_logging_in
  end

  scenario "Visiting a page beyond the last page returns not found" do
    when_i_visit_the_find_homepage
    when_i_click_login

    and_i_have_saved_courses
    when_i_visit_saved_courses_page(999)

    then_i_see_not_found
  end

  scenario "Visiting page 1 with no saved courses shows empty state" do
    when_i_visit_the_find_homepage
    when_i_click_login

    when_i_visit_saved_courses_page(1)

    then_i_see_no_saved_courses_message
  end

  def when_i_visit_the_find_homepage
    visit "/"
  end

  def when_i_click_login
    click_link_or_button "Sign in"
  end

  def then_i_see_that_i_am_logged_in
    expect(page).to have_content("You have been successfully signed in.")
  end

  def then_i_can_see_the_primary_navigation_links
    within ".govuk-service-navigation__container" do
      expect(page).to have_link("Find courses", href: find_root_path)
      expect(page).to have_link("Saved courses", href: find_candidate_saved_courses_path)
    end
  end

  def then_i_cant_see_the_primary_navigation_links
    within ".govuk-service-navigation__container" do
      expect(page).not_to have_link("Find courses", href: find_root_path)
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

    expect(page).to have_current_path(find_root_path)
    expect(page).to have_content("You must sign in to visit that page.")
  end

  def and_i_have_saved_courses
    candidate = Candidate.first
    create(:saved_course, course: create(:course, :published, :open, :with_full_time_sites), candidate: candidate)
  end

  def when_i_visit_saved_courses_page(page_number)
    visit find_candidate_saved_courses_path(page: page_number)
  end

  def then_i_see_not_found
    expect(page).to have_content("Page not found")
  end

  def then_i_see_no_saved_courses_message
    expect(page).to have_content("You have no saved courses")
  end
end
