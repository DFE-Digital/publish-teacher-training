require "rails_helper"

RSpec.describe "Support console Candidates saved courses" do
  let(:user) { create(:user, :admin) }

  before { given_i_am_authenticated }

  scenario "user sees candidates details" do
    when_a_candidates_exist
    and_i_visit_the_candidate_details
    then_i_see_the_saved_courses_of_the_candidate
  end

  def when_a_candidates_exist
    @candidate = create(:candidate)

    course = create(:course)
    @saved_course = create(:saved_course, candidate: @candidate, course:)
  end

  def and_i_visit_the_candidate_details
    visit saved_courses_support_candidate_path(@candidate)
  end

  def then_i_see_the_saved_courses_of_the_candidate
    expect(page).to have_content(@saved_course.course.name)
    expect(page).to have_content(@saved_course.course.course_code)
    expect(page).to have_content(@saved_course.course.provider_name)
    expect(page).to have_content(@saved_course.created_at.to_fs(:govuk_date_and_time))
  end

  def given_i_am_authenticated
    sign_in_system_test(user:)
  end
end
