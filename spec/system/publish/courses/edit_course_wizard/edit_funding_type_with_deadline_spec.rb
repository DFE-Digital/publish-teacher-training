# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a course's funding type and adding a visa sponsorship deadline", type: :system do
  around do |example|
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = false
  end

  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "changing salary to fee and sponsoring student visas saves the deadline date" do
    given_a_course_exists(funding: "salary", can_sponsor_skilled_worker_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_choose_and_continue "Fee - no salary"
    and_i_choose_and_continue "Yes"
    and_i_choose_and_continue "Yes"
    and_i_enter_the_deadline_and_continue

    then_i_am_on_the_course_details_page
    and_the_course_sponsors_student_visas_until_the_deadline
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

  def and_i_enter_the_deadline_and_continue
    fill_in "Day", with: deadline.day
    fill_in "Month", with: deadline.month
    fill_in "Year", with: deadline.year
    click_on "Continue"
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
  end

  def and_the_course_sponsors_student_visas_until_the_deadline
    course.reload
    expect(course.funding).to eq("fee")
    expect(course.can_sponsor_student_visa).to be(true)
    expect(course.visa_sponsorship_application_deadline_at.to_date).to eq(deadline)
  end

  def deadline
    Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_date - 1.day
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
