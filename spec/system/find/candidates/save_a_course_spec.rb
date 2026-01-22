require "rails_helper"

RSpec.describe "Saving a course", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course" do
    when_i_sign_in_as_a_candidate
    when_i_view_a_course
    then_i_save_the_course

    then_the_course_is_saved
  end

  scenario "An unauthenticated visitor is prompted to sign in when trying to save a course" do
    when_i_visit_a_course_without_signing_in

    then_i_am_prompted_to_sign_in_and_course_is_saved
    then_i_can_see_the_course_in_my_saved_courses
  end

  scenario "An unauthenticated visitor is redirected safely when the course no longer exists after sign in" do
    when_i_visit_a_course_without_signing_in

    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")

    @course.destroy!

    click_link_or_button("Continue")

    expect(page).to have_current_path(find_root_path)
    expect(page).not_to have_content("Course saved")
    expect(page).to have_content("Failed to save course")
  end

  scenario "An unauthenticated visitor sees an error if saving the course fails" do
    allow(Find::SaveCourseService).to receive(:call).and_return(nil)

    when_i_visit_a_course_without_signing_in

    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")
    click_link_or_button("Continue")

    expect(page).to have_current_path(find_course_path(provider_code: @course.provider_code, course_code: @course.course_code))
    expect(page).to have_content("Failed to save course")
    expect(page).not_to have_content("Course saved")
  end

  scenario "Saving a course is idempotent when it is already saved" do
    candidate = create(:find_developer_candidate)
    create(:saved_course, candidate:, course: @course)

    when_i_visit_a_course_without_signing_in

    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")
    click_link_or_button("Continue")

    expect(page).to have_content("Course saved")
    expect(SavedCourse.where(candidate_id: candidate.id, course_id: @course.id).count).to eq(1)
  end

  scenario "Saving a course fires the saved course analytics event" do
    analytics_event = instance_double(Find::Analytics::SavedCourseEvent)
    allow(analytics_event).to receive(:send_event)
    allow(Find::Analytics::SavedCourseEvent).to receive(:new).and_return(analytics_event)

    when_i_visit_a_course_without_signing_in
    then_i_am_prompted_to_sign_in_and_course_is_saved

    expect(analytics_event).to have_received(:send_event).at_least(:once)
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

  def then_i_save_the_course_as_an_unauthenticated_visitor
    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")
  end

  def then_the_course_is_saved
    expect(page).to have_content("Course saved")
  end

  def then_i_am_prompted_to_sign_in_and_course_is_saved
    expect(page).to have_content("Sign in to save this course")
    click_link_or_button("Sign in to save this course")

    click_link_or_button("Continue")

    expect(page).to have_content("Course saved")
    expect(page).to have_link("View saved courses", href: find_candidate_saved_courses_path)
  end

  def then_i_can_see_the_course_in_my_saved_courses
    click_link_or_button("View saved courses")
    expect(page).to have_current_path(find_candidate_saved_courses_path)
    expect(page).to have_content("York university")
    expect(page).to have_content("Art and design (SEND) (F314)")
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
