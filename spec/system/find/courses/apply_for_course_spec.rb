require "rails_helper"

RSpec.describe "Saving a course", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course" do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    when_i_view_a_course
    when_i_click_apply_for_this_course

    then_i_see_the_confirm_apply_page
  end

  scenario "A signed-in candidate sees a school experience interruption for salaried courses", travel: mid_cycle(2027) do
    given_a_salaried_course_with_required_school_experience_exists
    when_i_visit_confirm_apply_page

    then_i_see_the_school_experience_interruption_page
  end

  scenario "A signed-in candidate does not see the interruption for fee-funded courses", travel: mid_cycle(2027) do
    given_a_fee_course_without_required_school_experience_exists
    when_i_visit_confirm_apply_page

    then_i_see_the_confirm_apply_page
  end

  def when_i_view_a_course
    visit find_course_path(provider_code: @course.provider.provider_code, course_code: @course.course_code)
  end

  def when_i_visit_a_course_without_signing_in
    visit "/"
    visit find_results_path
    click_on_first_course
  end

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def when_i_click_apply_for_this_course
    page.find("a", text: "Apply for this course", match: :first).click
  end

  def when_i_visit_confirm_apply_page
    visit find_confirm_apply_path(provider_code: @course.provider.provider_code, course_code: @course.course_code)
  end

  def then_i_see_the_confirm_apply_page
    expect(page).to have_content("Back to #{@course.name_and_code}")
    expect(page).to have_content("Apply for this course")
    expect(page).to have_content("Continue to the Apply for teacher training website to apply for this course.")

    expected_href = find_track_apply_to_course_click_path(
      utm_content: "confirm_apply_course_button",
      course_id: @course.id,
      url: find_apply_path(provider_code: @course.provider.provider_code, course_code: @course.course_code),
    )

    expect(page).to have_link("Start now", href: expected_href)
  end

  def then_i_see_the_school_experience_interruption_page
    expect(page).to have_content("Back to #{@course.name_and_code}")
    expect(page).to have_content("Before you apply for this course")
    expect(page).to have_content("You need to confirm that you understand the school experience requirements")
    expect(page).to have_content("You must have completed 10 days of school experience in the last 12 months.")

    expect(page).to have_link(
      "For more information contact #{@course.provider_name}",
      href: find_provider_path(@course.provider_code, @course.course_code),
    )

    expected_href = find_track_apply_to_course_click_path(
      utm_content: "confirm_apply_course_button",
      course_id: @course.id,
      url: find_apply_path(provider_code: @course.provider.provider_code, course_code: @course.course_code),
    )

    expect(page).to have_link("Yes, I understand the school experience requirements", href: expected_href)
    expect(page).to have_link("Cancel and return to the course page", href: find_course_path(provider_code: @course.provider_code, course_code: @course.course_code))
    expect(page).to have_content("Is a salaried course right for me?")
    expect(page).to have_content("Get free one-to-one support")
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

  def given_a_salaried_course_with_required_school_experience_exists
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :salary,
      :published,
      :open,
      name: "Art and design (SEND)",
      course_code: "F314",
      school_experience_required: true,
      school_experience_required_content: "You must have completed 10 days of school experience in the last 12 months.",
      provider: create(:provider, provider_name: "York university"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end

  def given_a_fee_course_without_required_school_experience_exists
    @course = create(
      :course,
      :with_full_time_sites,
      :secondary,
      :fee,
      :published,
      :open,
      name: "Art and design (SEND)",
      course_code: "F314",
      school_experience_required: false,
      school_experience_required_content: nil,
      provider: create(:provider, provider_name: "York university"),
      subjects: [find_or_create(:secondary_subject, :art_and_design)],
    )
  end
end
