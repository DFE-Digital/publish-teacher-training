# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Returning to a course edit that has ended", type: :system do
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

  scenario "a question of a saved edit sends me to the course with a message" do
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_note_the_question_url
    and_i_click_continue

    when_i_visit_the_question_url_again
    then_i_am_on_the_course_details_page
    and_i_see_the_edit_has_ended
  end

private

  def when_i_visit_the_course_details_page
    visit course_details_path
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def and_i_note_the_question_url
    @question_url = page.current_path
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_visit_the_question_url_again
    visit @question_url
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
  end

  def and_i_see_the_edit_has_ended
    expect(page).to have_content("This change has already been saved or has expired. Check the course details.")
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
