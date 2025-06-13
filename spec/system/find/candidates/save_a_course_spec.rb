require "rails_helper"

RSpec.describe "Saving a course", :js, service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    given_courses_exist
  end

  scenario "As a signed in Candidate, I can save a course" do
    when_i_visit_the_find_homepage
    then_i_see_a_login_button

    when_i_click_login
    then_i_see_that_i_am_logged_in

    when_i_visit_the_results_page
    when_i_click_on_the_first_course

    when_i_save_the_course
    then_the_course_is_saved
  end

  scenario "As a not signed in Candidate, I cant save a course" do
    when_i_visit_the_find_homepage
    when_i_visit_the_results_page

    when_i_click_on_the_first_course
    when_i_save_the_course

    then_i_am_prompted_to_log_in
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

  def when_i_visit_the_results_page
    visit(find_results_path)
  end

  def when_i_click_on_the_first_course
    page.first(".app-search-results").first("a").click
  end

  def when_i_save_the_course
    expect(page).to have_content("Save this course for later")
    click_link_or_button("Save this course for later")
  end

  def then_the_course_is_saved
    expect(page).to have_content("Course saved")
  end

  def then_i_am_prompted_to_log_in
    expect(page).to have_content("You must login to view this page")
    expect(page).to have_current_path(new_find_sessions_path)
  end

  def given_courses_exist
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :published,
      :open,
      name: "Art and design (SEND)",
      course_code: "F314",
      provider: build(:provider, provider_name: "York university", provider_code: "RO1"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
