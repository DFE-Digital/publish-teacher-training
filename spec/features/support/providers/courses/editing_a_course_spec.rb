# frozen_string_literal: true

require "rails_helper"

feature "Edit provider course code" do
  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_with_courses
    when_i_visit_the_provider_courses_index_page
    and_click_on_the_first_course_code_edit_link
    then_i_am_on_the_course_edit_page
  end

  context "valid details" do
    scenario "I can edit a course code" do
      when_i_fill_in_a valid_course_code
      and_i_click_the_continue_button
      then_i_am_redirected_back_to_the_provider_courses_index_page
      and_the_course_code_is_updated
    end
  end

  context "invalid details" do
    scenario "I cannot use a taken course code" do
      when_i_fill_in_a existing_course_code
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "I cannot use a blank course code" do
      when_i_fill_in_a blank_course_code
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end
  end

private

  def given_i_am_authenticated_as_an_admin_user
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def provider
    @provider ||= create(:provider, courses: [build(:course), build(:course)])
  end

  def and_there_is_a_provider_with_courses
    provider
  end

  def when_i_visit_the_provider_courses_index_page
    provider_courses_index_page.load(provider_id: provider.id)
  end

  def and_click_on_the_first_course_code_edit_link
    provider_courses_index_page.courses_row.first.edit_link.click
  end

  def then_i_am_on_the_course_edit_page
    course_edit_page.load(provider_id: provider.id, course_id: provider.courses.first.id)
  end

  def course_code
    @course_code ||= "D0N3"
  end

  def valid_course_code
    @valid_course_code ||= course_code
  end

  def existing_course_code
    @existing_course_code ||= provider.courses.second.course_code
  end

  def blank_course_code
    @blank_course_code ||= ""
  end

  def when_i_fill_in_a(course_code)
    course_edit_page.course_code.set(course_code)
  end

  def and_i_click_the_continue_button
    course_edit_page.continue.click
  end

  def then_i_am_redirected_back_to_the_provider_courses_index_page
    expect(provider_courses_index_page).to be_displayed
  end

  def and_the_course_code_is_updated
    expect(provider_courses_index_page).to have_text(course_code)
  end

  def then_i_see_the_error_summary
    expect(course_edit_page.error_summary).to be_visible
  end
end
