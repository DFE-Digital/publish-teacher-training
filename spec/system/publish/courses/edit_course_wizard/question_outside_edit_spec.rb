# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Visiting a question outside a course edit", type: :system do
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

  scenario "a question the edit does not ask redirects to the edit's question" do
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_funding_type
    and_i_visit_the_level_question_of_the_edit
    then_i_am_on_the_funding_type_question_of_the_edit
  end

private

  def when_i_visit_the_course_details_page
    visit details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def and_i_visit_the_level_question_of_the_edit
    @funding_type_path = page.current_path
    visit @funding_type_path.sub(%r{/funding_type\z}, "/level")
  end

  def then_i_am_on_the_funding_type_question_of_the_edit
    expect(page).to have_current_path(@funding_type_path)
  end

  def provider
    @current_user.providers.first
  end
end
