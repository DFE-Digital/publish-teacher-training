# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a published course's visa sponsorship with the course wizard", type: :system do
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

  scenario "sponsoring student visas asks me to confirm, then publishes the change" do
    given_a_course_exists(:published, funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_student_visas
    and_i_choose_and_continue "Yes"
    and_i_choose_and_continue "No"

    then_i_am_asked_to_confirm_the_visa_sponsorship_changes
    and_the_course_is_unchanged

    when_i_click_on "Continue and publish changes"
    then_i_am_on_the_course_details_page
    and_i_see "Visa sponsorship updated"
    and_the_course_sponsors_student_visas
  end

private

  def when_i_visit_the_course_details_page
    visit course_details_path
  end

  def and_i_click_change_student_visas
    click_on "Change can sponsor student visa"
  end

  def and_i_choose_and_continue(label)
    choose label
    click_on "Continue"
  end

  def then_i_am_asked_to_confirm_the_visa_sponsorship_changes
    expect(page).to have_content("Are you sure you want to publish your changes to 'Visa sponsorship'?")
    expect(page).to have_content("Your changes will go live immediately.")
  end

  def and_the_course_is_unchanged
    expect(course.reload.can_sponsor_student_visa).to be(false)
  end

  def when_i_click_on(text)
    click_on text
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
  end

  def and_i_see(text)
    expect(page).to have_content(text)
  end

  def and_the_course_sponsors_student_visas
    expect(course.reload.can_sponsor_student_visa).to be(true)
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
