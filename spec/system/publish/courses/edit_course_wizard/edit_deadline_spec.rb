# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a published course's visa sponsorship deadline with the course wizard", type: :system do
  around do |example|
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = false
  end

  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "the deadline Change link starts at the visa question, and removing the deadline publishes after I confirm" do
    given_a_course_exists(:published, funding: "fee", can_sponsor_student_visa: true, accrediting_provider: provider,
                                      visa_sponsorship_application_deadline_at: deadline)
    when_i_visit_the_course_details_page
    and_i_click_change_the_deadline

    then_i_see "Student visas"

    when_i_choose_and_continue "Yes"
    and_i_choose_and_continue "No"
    and_i_click_on "Continue and publish changes"

    then_i_see "Visa sponsorship updated"
    and_the_course_has_no_deadline
  end

private

  def when_i_visit_the_course_details_page
    visit course_details_path
  end

  def and_i_click_change_the_deadline
    click_on "Change deadline for candidates requiring sponsorship"
  end

  def when_i_choose_and_continue(label)
    choose label
    click_on "Continue"
  end
  alias_method :and_i_choose_and_continue, :when_i_choose_and_continue

  def and_i_click_on(text)
    click_on text
  end

  def then_i_see(text)
    expect(page).to have_content(text)
  end

  def and_the_course_has_no_deadline
    course.reload
    expect(course.can_sponsor_student_visa).to be(true)
    expect(course.visa_sponsorship_application_deadline_at).to be_nil
  end

  def deadline
    (Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year) - 1.day).end_of_day
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
