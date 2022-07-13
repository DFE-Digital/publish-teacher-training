# frozen_string_literal: true

require "rails_helper"

feature "Deleting courses", { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "i can delete a course" do
    and_there_is_a_course_i_want_to_delete
    when_i_visit_the_course_page
    and_i_click_the_delete_link
    and_i_confirm_the_course_code
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_is_deleted
  end

  scenario "wrong course code provided" do
    and_there_is_a_course_i_want_to_delete
    when_i_visit_the_delete_page
    and_i_submit_with_the_wrong_code
    then_i_should_see_an_error_message
  end

  scenario "attempting to delete a published course" do
    and_there_is_a_published_course
    when_i_visit_the_delete_page
    then_i_am_redirected_to_the_courses_page
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_delete
    given_a_course_exists(enrichments: [build(:course_enrichment, :initial_draft)])
  end

  def and_there_is_a_published_course
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_course_page
    provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_delete_page
    delete_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_click_the_delete_link
    provider_courses_show_page.course_button_panel.delete_link.click
  end

  def and_i_confirm_the_course_code
    delete_page.confirm_course_code.set(course.course_code)
  end

  def and_i_submit_with_the_wrong_code
    delete_page.confirm_course_code.set("random")
    and_i_submit
  end

  def and_i_submit
    delete_page.submit.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content("#{course_name_and_code} has been deleted")
  end

  def and_the_course_is_deleted
    expect(course.reload).to be_discarded
  end

  def then_i_am_redirected_to_the_courses_page
    expect(provider_courses_index_page).to be_displayed
  end

  def then_i_should_see_an_error_message
    expect(delete_page.error_messages).to include(
      "Enter the course code #{course.course_code} to delete this course",
    )
  end

  def provider
    @current_user.providers.first
  end

  def course_name_and_code
    "#{course.name} (#{course.course_code})"
  end
end
