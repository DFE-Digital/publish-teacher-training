require "rails_helper"

RSpec.describe "Saving a course", service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    CandidateAuthHelper.mock_auth
    given_a_published_course_exists
  end

  scenario "A signed-in candidate can save a course" do
    when_i_view_a_course
    when_i_click_apply_for_this_course

    then_i_see_the_confirm_apply_page
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

  def click_on_first_course
    page.first(".app-search-results").first("a").click
  end

  def when_i_click_apply_for_this_course
    page.find("a", text: "Apply for this course", match: :first).click
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
