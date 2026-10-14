# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The visa Change links with the course edit wizard off", type: :system do
  before do
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  scenario "the student visa link goes to the student visa page" do
    given_a_course_exists(:published, funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_student_visas
    then_i_am_on_the_student_visa_page
  end

private

  def when_i_visit_the_course_details_page
    visit details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def and_i_click_change_student_visas
    click_on "Change can sponsor student visa"
  end

  def then_i_am_on_the_student_visa_page
    expect(page).to have_current_path(
      student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(
        provider.provider_code, provider.recruitment_cycle_year, course.course_code, back_to_basic_details: true
      ),
    )
  end

  def provider
    @current_user.providers.first
  end
end
