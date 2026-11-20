# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Saving a course edit after someone else changed the course", type: :system do
  around do |example|
    previous = Settings.features.course_edit_wizard
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = previous
  end

  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "the edit is not saved and I see why" do
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_choose_and_continue "Salary"
    and_someone_else_changes_the_course
    and_i_choose_and_continue "Yes"
    and_i_choose_and_continue "No"

    then_i_am_on_the_course_details_page
    and_i_see_the_course_was_changed_by_someone_else
    and_the_course_is_still_fee_paying
  end

private

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

  def and_someone_else_changes_the_course
    course.touch
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
  end

  def and_i_see_the_course_was_changed_by_someone_else
    expect(page).to have_content("This course was changed by someone else. Your changes were not saved.")
  end

  def and_the_course_is_still_fee_paying
    expect(course.reload.funding).to eq("fee")
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
