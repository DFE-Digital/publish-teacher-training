# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The funding type Change link with the course edit wizard off", type: :system do
  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "the link goes to the funding type page" do
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    then_i_am_on_the_funding_type_page
  end

private

  def when_i_visit_the_course_details_page
    visit details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def then_i_am_on_the_funding_type_page
    expect(page).to have_current_path(
      funding_type_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code),
    )
  end

  def provider
    @current_user.providers.first
  end
end
