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

    when_i_save_the_course

    then_the_course_is_saved
  end

  scenario "An unauthenticated visitor is prompted to sign in when trying to save a course" do
    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    when_i_save_the_course_as_an_unauthenticated_visitor
    then_i_am_redirected_to_sign_in_page_from_results
    when_i_continue_sign_in
    then_i_am_back_on_results_page
    then_the_course_is_saved
  end

  scenario "An unauthenticated visitor is redirected safely when the course no longer exists after sign in" do
    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    when_i_save_the_course_as_an_unauthenticated_visitor
    then_i_am_redirected_to_sign_in_page_from_results

    @course.destroy!

    when_i_continue_sign_in

    then_i_am_redirected_to_find_root
    then_i_see_failed_to_save_course
  end

  scenario "An unauthenticated visitor sees an error if saving the course fails" do
    allow(Find::SaveCourseService).to receive(:call).and_return(nil)

    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    when_i_save_the_course_as_an_unauthenticated_visitor
    then_i_am_redirected_to_sign_in_page_from_results
    when_i_continue_sign_in

    then_i_am_back_on_results_page
    then_i_see_failed_to_save_course
    then_i_do_not_see_course_saved
  end

  scenario "Saving a course is idempotent when it is already saved" do
    candidate = create(:find_developer_candidate)
    create(:saved_course, candidate:, course: @course)

    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    when_i_save_the_course_as_an_unauthenticated_visitor
    then_i_am_redirected_to_sign_in_page_from_results
    when_i_continue_sign_in

    then_i_am_back_on_results_page
    then_the_course_is_saved
    then_the_course_is_saved_once_for(candidate:, course: @course)
  end

  scenario "Saving a course fires the saved course analytics event" do
    analytics_event = instance_double(Find::Analytics::SavedCourseEvent)
    allow(analytics_event).to receive(:send_event)
    allow(Find::Analytics::SavedCourseEvent).to receive(:new).and_return(analytics_event)

    when_i_visit_a_course_without_signing_in
    when_i_visit_the_results_page

    when_i_save_the_course_as_an_unauthenticated_visitor
    then_i_am_redirected_to_sign_in_page_from_results
    when_i_continue_sign_in

    then_i_am_back_on_results_page
    then_the_course_is_saved
    then_saved_course_analytics_event_is_sent(analytics_event)
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
  end

  def when_i_save_the_course
    expect(page).to have_content("Save")
    click_link_or_button("Save")
  end

  def when_i_save_the_course_as_an_unauthenticated_visitor
    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")
  end

  def then_the_course_is_saved
    within(".results-save-course-button__unstyled-button") do
      expect(page).to have_css(".save-course-button__text", text: "Saved")
    end
  end

  def then_i_do_not_see_course_saved
    within(".results-save-course-button__unstyled-button") do
      expect(page).not_to have_css(".save-course-button__text", text: "Saved")
    end
  end

  def then_i_am_redirected_to_sign_in_page_from_results
    expect(page).to have_current_path(
      sign_in_find_candidate_saved_courses_path(course_id: @course.id, return_to: find_results_path),
    )
    expect(page).to have_content("Sign in to save this course")
  end

  def when_i_continue_sign_in
    click_link_or_button("Continue")
  end

  def then_i_am_back_on_results_page
    expect(page).to have_current_path(find_results_path)
  end

  def then_i_am_redirected_to_find_root
    expect(page).to have_current_path(find_root_path)
  end

  def then_i_see_failed_to_save_course
    expect(page).to have_content("Failed to save course")
  end

  def then_the_course_is_saved_once_for(candidate:, course:)
    expect(SavedCourse.where(candidate_id: candidate.id, course_id: course.id).count).to eq(1)
  end

  def then_saved_course_analytics_event_is_sent(analytics_event)
    expect(analytics_event).to have_received(:send_event).at_least(:once)
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
