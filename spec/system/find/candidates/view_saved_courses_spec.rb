require "rails_helper"

RSpec.describe "Viewing my saved courses", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A candidate can view their saved courses" do
    when_i_log_in_as_a_candidate
    when_i_have_saved_courses

    then_i_visit_my_saved_courses

    then_i_view_my_saved_courses
    then_the_back_link_takes_me_back_to_the_saved_courses_page
  end

  scenario "A candidate can view the saved courses page with no saved courses" do
    when_i_log_in_as_a_candidate
    then_i_visit_my_saved_courses

    then_i_see_no_saved_courses_message
  end

  def then_i_see_no_saved_courses_message
    expect(page).to have_content("You have no saved courses.")
  end

  def then_i_view_my_saved_courses
    within(all(".govuk-table__row").first) do
      expect(page).to have_content(@course.provider.provider_name)
      expect(page).to have_content(@course.name)
      expect(page).to have_content(@course.course_code)
      expect(page).to have_content("Delete")

      expect(page).to have_link(
        @course.provider.provider_name,
        href: find_course_path(
          provider_code: @course.provider_code,
          course_code: @course.course_code,
        ),
      )
    end
  end

  def then_the_back_link_takes_me_back_to_the_saved_courses_page
    click_link_or_button @course.provider.provider_name
    expect(page).to have_link("Back to saved courses", href: find_candidate_saved_courses_path)
  end

  def when_i_log_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def then_i_visit_my_saved_courses
    click_link_or_button "Saved courses"
  end

  def when_i_have_saved_courses
    candidate = Candidate.first
    @saved_courses = create(:saved_course, course: @course, candidate: candidate)
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
