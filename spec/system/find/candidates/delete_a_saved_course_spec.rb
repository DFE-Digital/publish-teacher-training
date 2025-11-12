require "rails_helper"

RSpec.describe "Deleting a saved course", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can delete a saved course" do
    when_i_sign_in_as_a_candidate
    when_i_view_a_course
    then_i_save_the_course

    then_the_course_is_saved

    when_i_visit_my_saved_courses
    then_i_see_my_saved_course
    then_i_delete_a_saved_course
  end

  def then_i_delete_a_saved_course
    click_link_or_button "Delete"
    expect(page).to have_content("Saved course deleted")
  end

  def when_i_visit_my_saved_courses
    visit find_candidate_saved_courses_path
  end

  def then_i_see_my_saved_course
    expect(page).to have_content(@course.provider_name)
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content("Delete")
  end

  def when_i_sign_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_view_a_course
    visit find_results_path
    click_on_first_course
  end

  def when_i_visit_a_course_without_signing_in
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
