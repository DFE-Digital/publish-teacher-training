# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a course's funding type with the course wizard", type: :system do
  around do |example|
    Settings.features.course_edit_wizard = true
    example.run
  ensure
    Settings.features.course_edit_wizard = false
  end

  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "changing fee to salary asks the visa questions, then saves and returns to the course" do
    given_there_is_a_fee_paying_course_that_cannot_sponsor_student_visas
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    then_i_am_on_the_funding_type_page_for_the_course

    when_i_choose "Salary"
    and_i_click_continue
    then_i_am_on_the_skilled_worker_visa_page

    when_i_choose "Yes"
    and_i_click_continue
    then_i_am_on_the_deadline_required_page

    when_i_choose "No"
    and_i_click_continue
    then_i_am_on_the_course_details_page
    and_i_see_the_funding_type_updated_message
    and_the_course_is_salaried_and_sponsors_skilled_worker_visas_only
  end

private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  def given_there_is_a_fee_paying_course_that_cannot_sponsor_student_visas
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
  end

  def when_i_visit_the_course_details_page
    visit details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def then_i_am_on_the_funding_type_page_for_the_course
    expect(page).to have_current_path(%r{/courses/#{course.course_code}/edit/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/funding_type\z})
    expect(page).to have_content(course.name_and_code)
    expect(page).to have_content("Funding type")
  end

  def when_i_choose(label)
    choose label
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_on_the_skilled_worker_visa_page
    expect(page).to have_content("Can your organisation sponsor Skilled Worker visas for this course?")
  end

  def then_i_am_on_the_deadline_required_page
    expect(page).to have_content("Is there a deadline for applications that require visa sponsorship?")
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(
      details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code),
    )
  end

  def and_i_see_the_funding_type_updated_message
    within(".govuk-notification-banner") do
      expect(page).to have_content("Funding type updated")
    end
  end

  def and_the_course_is_salaried_and_sponsors_skilled_worker_visas_only
    course.reload
    expect(course.funding).to eq("salary")
    expect(course.can_sponsor_skilled_worker_visa).to be(true)
    expect(course.can_sponsor_student_visa).to be(false)
  end

  def provider
    @current_user.providers.first
  end
end
