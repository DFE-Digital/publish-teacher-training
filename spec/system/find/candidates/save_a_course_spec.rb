require "rails_helper"

RSpec.describe "Saving a course", :js, service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course" do
    when_i_log_in_as_a_candidate
    when_i_view_a_course
    then_i_save_the_course

    then_the_course_is_saved
  end

  scenario "An unauthenticated visitor is prompted to log in when trying to save a course" do
    when_i_visit_a_course_without_logging_in
    then_i_save_the_course

    then_i_am_prompted_to_log_in
  end

  def when_i_log_in_as_a_candidate
    visit "/"
    click_link_or_button "Login"
    expect(page).to have_content("You're logged in!")
  end

  def when_i_view_a_course
    visit find_results_path
    click_on_first_course
  end

  def when_i_visit_a_course_without_logging_in
    visit "/"
    visit find_results_path
    click_on_first_course
  end

  def then_i_save_the_course
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

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def given_a_published_course_exists
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
