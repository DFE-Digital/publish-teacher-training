# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Saving a course edit that the course rejects", type: :system do
  around do |example|
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = false
  end

  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "a salaried course that requires school experience cannot become fee paying" do
    given_a_salaried_course_that_requires_school_experience
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_choose_and_continue "Fee - no salary"
    and_i_choose_and_continue "No"

    then_i_am_on_the_course_details_page
    and_i_see_my_changes_were_not_saved
    and_the_course_is_still_salaried
  end

private

  def given_a_salaried_course_that_requires_school_experience
    given_a_course_exists(
      funding: "salary",
      can_sponsor_skilled_worker_visa: false,
      accrediting_provider: provider,
      school_experience_required: true,
      school_experience_required_content: "Two weeks in a school",
    )
  end

  def when_i_visit_the_course_details_page
    visit course_details_path
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def and_i_choose_and_continue(label)
    choose label
    click_on "Continue"
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
  end

  def and_i_see_my_changes_were_not_saved
    expect(page).to have_content("Your changes were not saved")
    expect(page).to have_content("School experience required can only be required for salaried or apprenticeship courses")
  end

  def and_the_course_is_still_salaried
    expect(course.reload.funding).to eq("salary")
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
