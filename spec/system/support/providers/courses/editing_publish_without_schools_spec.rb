# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing publish without schools as support", travel: mid_cycle do
  before do
    given_i_am_authenticated_as_an_admin_user
  end

  context "with a salaried course" do
    scenario "I can approve the course to publish without schools" do
      when_i_visit_the_edit_page_for(salaried_course)
      then_i_see_the_publish_without_schools_checkbox
      when_i_tick_the_publish_without_schools_checkbox
      and_i_click_the_update_button
      then_the_course_is_allowed_to_publish_without_schools(salaried_course)
      when_i_visit_the_edit_page_for(salaried_course)
      then_the_publish_without_schools_checkbox_is_ticked
    end
  end

  context "when the course details are invalid" do
    scenario "my ticked publish without schools checkbox survives the error" do
      when_i_visit_the_edit_page_for(salaried_course)
      when_i_tick_the_publish_without_schools_checkbox
      and_i_enter_an_invalid_start_date
      and_i_click_the_update_button
      then_i_see_a_start_date_error
      and_the_publish_without_schools_checkbox_is_still_ticked
    end
  end

  context "with an apprenticeship course" do
    scenario "I see the publish without schools checkbox" do
      when_i_visit_the_edit_page_for(apprenticeship_course)
      then_i_see_the_publish_without_schools_checkbox
    end
  end

  context "with a fee course" do
    scenario "I see the publish without schools checkbox" do
      when_i_visit_the_edit_page_for(fee_course)
      then_i_see_the_publish_without_schools_checkbox
    end
  end

private

  def given_i_am_authenticated_as_an_admin_user
    Timecop.travel(1.second.from_now)
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def provider
    @provider ||= create(:provider)
  end

  def salaried_course
    @salaried_course ||= create(:course, :with_salary, provider:)
  end

  def apprenticeship_course
    @apprenticeship_course ||= create(:course, :apprenticeship, provider:)
  end

  def fee_course
    @fee_course ||= create(:course, funding: "fee", provider:)
  end

  def when_i_visit_the_edit_page_for(course)
    support_provider_course_edit_page.load(
      recruitment_cycle_year: provider.recruitment_cycle_year,
      provider_id: provider.id,
      course_id: course.id,
    )
  end

  def then_i_see_the_publish_without_schools_checkbox
    expect(support_provider_course_edit_page).to have_publish_without_schools_allowed_checkbox
    expect(support_provider_course_edit_page).to have_text("Publishing this course without schools")
    expect(support_provider_course_edit_page).to have_text("Only tick this box if you have confirmed that this provider is allowed to publish courses without schools attached.")
    expect(support_provider_course_edit_page).to have_text("Allow this course to be published without schools attached")
  end

  def when_i_tick_the_publish_without_schools_checkbox
    support_provider_course_edit_page.publish_without_schools_allowed_checkbox.check
  end

  def and_i_click_the_update_button
    support_provider_course_edit_page.continue.click
  end

  def and_i_enter_an_invalid_start_date
    support_provider_course_edit_page.start_date_month.set("13")
  end

  def then_i_see_a_start_date_error
    expect(page).to have_content("Start date format is invalid", wait: 0)
  end

  def then_the_course_is_allowed_to_publish_without_schools(course)
    expect(course.reload.publish_without_schools_allowed).to be(true)
  end

  def then_the_publish_without_schools_checkbox_is_ticked
    expect(support_provider_course_edit_page.publish_without_schools_allowed_checkbox).to be_checked
  end

  # have_checked_field returns false rather than raising, so a missing or
  # unticked checkbox fails here immediately instead of waiting on Capybara.
  def and_the_publish_without_schools_checkbox_is_still_ticked
    expect(page).to have_checked_field("Allow this course to be published without schools attached", wait: 0)
  end
end
