# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Going back from the first question of a course edit", type: :system do
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

  scenario "Back on the funding type question returns to the course without saving" do
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_choose_salary_and_continue
    and_i_click_back
    then_i_am_on_the_funding_type_page

    when_i_click_back
    then_i_am_on_the_course_details_page
    and_the_course_is_still_fee_paying
  end

private

  def when_i_visit_the_course_details_page
    visit course_details_path
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def and_i_choose_salary_and_continue
    choose "Salary"
    click_on "Continue"
  end

  def and_i_click_back
    click_on "Back"
  end
  alias_method :when_i_click_back, :and_i_click_back

  def then_i_am_on_the_funding_type_page
    expect(page).to have_current_path(%r{/edit/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/funding_type\z})
  end

  def then_i_am_on_the_course_details_page
    expect(page).to have_current_path(course_details_path)
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
