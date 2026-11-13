require "rails_helper"

RSpec.describe "Saving a course in a grouped result card", :js, service: :find do
  before do
    FeatureFlag.activate(:candidate_accounts)
    FeatureFlag.activate(:group_search_results)
    CandidateAuthHelper.mock_auth
    given_a_provider_has_two_maths_courses
  end

  scenario "A signed-in candidate saves one course on the card" do
    when_i_sign_in_as_a_candidate
    when_i_visit_the_results_page
    then_both_courses_are_on_one_card

    when_i_save(@second_course)

    then_only_it_is_saved(@second_course)
    and_the_other_course_can_still_be_saved(@first_course)
  end

  scenario "A visitor signs in to save one course on the card" do
    when_i_visit_the_results_page

    when_i_sign_in_to_save(@second_course)
    then_i_am_asked_to_sign_in_to_save(@second_course)
    when_i_continue_sign_in

    then_i_am_back_on_results_page
    then_only_it_is_saved(@second_course)
  end

  def given_a_provider_has_two_maths_courses
    provider = create(:provider, provider_name: "Bishop Challoner")
    mathematics = find_or_create(:secondary_subject, :mathematics)

    @first_course, @second_course = %w[M001 M002].map do |course_code|
      create(:course, :with_full_time_sites, :secondary, :published, :open, provider:, name: "Mathematics", course_code:, subjects: [mathematics])
    end
  end

  def when_i_sign_in_as_a_candidate
    visit "/"
    click_link_or_button "Sign in"
    expect(page).to have_content("You have been successfully signed in.")
  end

  def when_i_visit_the_results_page
    visit find_results_path
  end

  def then_both_courses_are_on_one_card
    expect(page).to have_css(".app-search-results__item", count: 1)
    expect(page).to have_css(".app-search-results__item .app-search-result__course", count: 2)
  end

  def within_course(course, &)
    within(".app-search-result__course", text: "(#{course.course_code})", &)
  end

  def when_i_save(course)
    within_course(course) { click_link_or_button("Save", exact: true) }
  end

  def when_i_sign_in_to_save(course)
    within_course(course) { click_link_or_button("Sign in to save this course") }
  end

  def then_only_it_is_saved(course)
    within_course(course) do
      expect(page).to have_css(".save-course-button__text", exact_text: "Saved")
    end
    expect(SavedCourse.pluck(:course_id)).to eq([course.id])
  end

  def and_the_other_course_can_still_be_saved(course)
    within_course(course) do
      expect(page).to have_css(".save-course-button__text", exact_text: "Save")
    end
  end

  def then_i_am_asked_to_sign_in_to_save(course)
    expect(page).to have_current_path(sign_in_find_candidate_saved_courses_path(course_id: course.id))
  end

  def when_i_continue_sign_in
    click_link_or_button("Continue")
  end

  def then_i_am_back_on_results_page
    expect(page).to have_current_path(find_results_path)
  end
end
