# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Going back from the confirm page of a published course edit", type: :system do
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

  scenario "Back goes to the last question, and continuing returns to the confirm page" do
    given_a_course_exists(:published, funding: "fee", can_sponsor_student_visa: false, accrediting_provider: provider)
    when_i_visit_the_course_details_page
    and_i_click_change_student_visas
    and_i_choose_and_continue "Yes"
    and_i_choose_and_continue "No"
    and_i_click_back

    then_i_see "Is there a deadline for applications that require visa sponsorship?"

    when_i_click_continue
    then_i_see "Are you sure you want to publish your changes to 'Visa sponsorship'?"
    and_the_course_is_unchanged
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

  def and_i_click_back
    click_on "Back"
  end

  def when_i_click_continue
    click_on "Continue"
  end

  def then_i_see(text)
    expect(page).to have_content(text)
  end

  def and_the_course_is_unchanged
    expect(course.reload.can_sponsor_student_visa).to be(false)
  end

  def course_details_path
    details_publish_provider_recruitment_cycle_course_path(provider.provider_code, provider.recruitment_cycle_year, course.course_code)
  end

  def provider
    @current_user.providers.first
  end
end
