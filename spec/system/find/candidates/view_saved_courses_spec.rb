require "rails_helper"

RSpec.describe "Viewing my saved courses", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A candidate can view their saved courses" do
    when_i_log_in_as_a_candidate
    and_i_have_saved_courses

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
    expect(page).to have_content("You have no saved courses")
    expect(page).to have_link("Find a course", href: find_root_path)
    expect(page).to have_content("and start saving courses you may want to review and apply for later.")
  end

  def then_i_view_my_saved_courses
    within_first_saved_course_row do
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

  context "saved status tag across cycle stages" do
    scenario "Apply has closed but old Find courses are still there shows Closed" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(apply_deadline))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Closed")
    end

    scenario "Find has re-opened but Apply hasn’t opened yet shows Not yet open" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(find_opens))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Not yet open")
    end

    scenario "Both Find and Apply are open, provider closed course early shows Closed" do
      given_a_published_course_exists
      Timecop.travel(1.day.after(apply_opens))
      @course.update!(application_status: :closed)

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Closed")
    end

    scenario "Withdrawn course shows Withdrawn" do
      given_a_withdrawn_course_exists
      Timecop.travel(1.day.after(apply_opens))

      when_i_log_in_as_a_candidate
      and_i_have_saved_courses
      then_i_visit_my_saved_courses

      then_i_should_see_in_first_saved_course_row("Withdrawn")
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

  def and_i_have_saved_courses
    candidate = Candidate.first
    @saved_courses = create(:saved_course, course: @course, candidate: candidate)
  end

  def within_first_saved_course_row(&block)
    within(all(".govuk-table__row").first, &block)
  end

  def then_i_should_see_in_first_saved_course_row(text)
    within_first_saved_course_row do
      expect(page).to have_content(text)
    end
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
      provider: build(:provider),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end

  def given_a_withdrawn_course_exists
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :with_special_education_needs,
      :withdrawn,
      name: "Art and design (SEND)",
      course_code: "F315",
      provider: build(:provider),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
