require "rails_helper"

RSpec.describe "Viewing a saved course published without an employing school", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:course_publishing_uses_new_school_model)
    CandidateAuthHelper.mock_auth
    given_a_school_less_salaried_course_exists
  end

  scenario "the saved course card shows the no-employing-schools text" do
    when_i_log_in_as_a_candidate
    and_i_have_saved_the_school_less_course

    when_i_visit_my_saved_courses

    then_i_see_the_course_listed
    and_i_see_no_employing_schools_listed
  end

  def given_a_school_less_salaried_course_exists
    @provider = create(:provider, provider_name: "Salaried Provider")
    @course = create(
      :course,
      :with_salary,
      :published,
      name: "Chemistry",
      course_code: "K592",
      application_status: "open",
      publish_without_schools_allowed: true,
      provider: @provider,
    )
  end

  def when_i_log_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def and_i_have_saved_the_school_less_course
    create(:saved_course, course: @course, candidate: Candidate.first)
  end

  def when_i_visit_my_saved_courses
    click_link_or_button "Saved courses"
  end

  def then_i_see_the_course_listed
    expect(page).to have_content(@course.name_and_code)
  end

  def and_i_see_no_employing_schools_listed
    within(".course-summary-card") do
      expect(page).to have_content("No employing schools listed")
      expect(page).to have_no_content("Add a location to see the nearest potential placement school")
    end
  end
end
