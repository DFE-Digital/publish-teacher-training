require "rails_helper"

RSpec.describe "Saving a course on the results page", :js, service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course" do
    when_i_sign_in_as_a_candidate
    when_i_visit_the_results_page

    then_i_save_the_course

    then_the_course_is_saved
  end

  scenario "An unauthenticated visitor is prompted to sign in when trying to save a course" do
    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    then_i_save_the_course

    then_i_am_prompted_to_sign_in
  end

  def when_i_sign_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def when_i_visit_a_course_without_signing_in
    visit "/"
    visit find_results_path
    click_on_first_course
  end

  def then_i_save_the_course
    expect(page).to have_content("Save")
    click_link_or_button("Save")
  end

  def then_the_course_is_saved
    expect(page).to have_content("Saved")
  end

  def then_i_am_prompted_to_sign_in
    expect(page).to have_content("You must sign in to visit that page.")
    expect(page).to have_current_path(find_root_path)
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
