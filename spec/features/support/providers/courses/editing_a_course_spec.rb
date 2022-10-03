# frozen_string_literal: true

require "rails_helper"

feature "Edit provider course details" do
  around do |example|
    Timecop.freeze(2021, 8, 1, 12) do
      example.run
    end
  end

  before do
    given_i_am_authenticated_as_an_admin_user
    and_there_is_a_provider_with_courses
    when_i_visit_the_support_courses_index_page
    and_click_on_the_first_course_change_link
    then_i_am_on_the_support_course_edit_page
  end

  context "valid details" do
    scenario "I can edit a course details" do
      when_i_fill_in_course_code_with valid_course_code
      and_i_fill_in_course_title_with valid_course_name
      and_i_fill_in_course_start_date_with valid_date_day, valid_date_month, valid_date_year
      and_i_fill_in_course_application_open_from_with valid_date_day, valid_date_month, valid_date_year
      and_i_select_the_send_checkbox
      and_i_click_the_continue_button
      then_i_am_redirected_back_to_the_support_courses_index_page
      and_the_course_name_and_code_are_updated
      when_i_return_to_the_edit_page
      then_i_see_the_updated_start_date
      then_i_see_the_updated_applications_open_from_date
      and_i_see_the_updated_send_specialism
    end
  end

  context "invalid details" do
    scenario "I cannot use invalid course details" do
      when_i_fill_in_course_code_with existing_course_code
      and_i_fill_in_course_title_with valid_course_name
      and_i_fill_in_course_start_date_with valid_date_day, valid_date_month, invalid_date_year
      and_i_fill_in_course_application_open_from_with valid_date_day, valid_date_month, invalid_date_year
      and_i_click_the_continue_button
      then_i_see_the_error_summary
      and_it_contains_invalid_value_errors
    end

    scenario "I cannot use invalid date format" do
      when_i_fill_in_course_start_date_with invalid_date_day, invalid_date_month, valid_date_year
      and_i_fill_in_course_application_open_from_with invalid_date_day, invalid_date_month, valid_date_year
      and_i_click_the_continue_button
      then_i_see_the_error_summary
      and_it_contains_start_date_format_error
      and_it_contains_applications_open_from_format_error
    end

    scenario "I cannot use a blank course details" do
      when_i_fill_in_course_code_with blank_value
      and_i_fill_in_course_title_with blank_value
      and_i_fill_in_course_start_date_with blank_value, blank_value, blank_value
      and_i_fill_in_course_application_open_from_with blank_value, blank_value, blank_value
      and_i_click_the_continue_button
      then_i_see_the_error_summary
      and_it_contains_blank_errors
    end
  end

private

  def given_i_am_authenticated_as_an_admin_user
    Timecop.travel(1.second.from_now)
    given_i_am_authenticated(user: create(:user, :admin))
  end

  def provider
    @provider ||= create(:provider, courses: [build(:course), build(:course)])
  end

  def and_there_is_a_provider_with_courses
    provider
  end

  def when_i_visit_the_support_courses_index_page
    support_courses_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id)
  end

  def and_click_on_the_first_course_change_link
    support_courses_index_page.courses_row.first.change_link.click
  end

  alias_method :when_i_return_to_the_edit_page, :and_click_on_the_first_course_change_link

  def then_i_am_on_the_support_course_edit_page
    support_course_edit_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_id: provider.id, course_id: provider.courses.first.id)
  end

  def course_code
    @course_code ||= "D0N3"
  end

  def course_name
    @course_name ||= "Geography"
  end

  def valid_date_day
    @valid_date_day ||= "1"
  end

  def invalid_date_day
    @invalid_date_day ||= "111"
  end

  def valid_date_month
    @valid_date_month ||= "10"
  end

  def invalid_date_month
    @invalid_date_month ||= "90"
  end

  def valid_course_code
    @valid_course_code ||= course_code
  end

  def valid_course_name
    @valid_course_name ||= course_name
  end

  def existing_course_code
    @existing_course_code ||= provider.courses.second.course_code
  end

  def valid_date_year
    @valid_date_year ||= (Settings.current_recruitment_cycle_year.to_i - 1).to_s
  end

  def invalid_date_year
    @invalid_date_year ||= (Settings.current_recruitment_cycle_year.to_i + 3).to_s
  end

  def blank_value
    @blank_value ||= ""
  end

  def when_i_fill_in_course_code_with(course_code)
    support_course_edit_page.course_code.set(course_code)
  end

  def and_i_fill_in_course_title_with(course_name)
    support_course_edit_page.name.set(course_name)
  end

  def when_i_fill_in_course_start_date_with(day, month, year)
    support_course_edit_page.start_date_day.set(day)
    support_course_edit_page.start_date_month.set(month)
    support_course_edit_page.start_date_year.set(year)
  end

  def when_i_fill_in_course_application_open_from_with(day, month, year)
    support_course_edit_page.application_open_from_day.set(day)
    support_course_edit_page.application_open_from_month.set(month)
    support_course_edit_page.application_open_from_year.set(year)
  end

  alias_method :and_i_fill_in_course_start_date_with, :when_i_fill_in_course_start_date_with
  alias_method :and_i_fill_in_course_application_open_from_with, :when_i_fill_in_course_application_open_from_with

  def and_i_click_the_continue_button
    support_course_edit_page.continue.click
  end

  def then_i_am_redirected_back_to_the_support_courses_index_page
    expect(support_courses_index_page).to be_displayed
  end

  def and_the_course_name_and_code_are_updated
    expect(support_courses_index_page).to have_text(course_code)
    expect(support_courses_index_page).to have_text(course_name)
  end

  def and_i_select_the_send_checkbox
    support_course_edit_page.send_specialism_checkbox.check
  end

  def then_i_see_the_updated_start_date
    expect(support_course_edit_page.start_date_day.value).to eq(valid_date_day)
    expect(support_course_edit_page.start_date_month.value).to eq(valid_date_month)
    expect(support_course_edit_page.start_date_year.value).to eq(valid_date_year)
  end

  def then_i_see_the_updated_applications_open_from_date
    expect(support_course_edit_page.application_open_from_day.value).to eq(valid_date_day)
    expect(support_course_edit_page.application_open_from_month.value).to eq(valid_date_month)
    expect(support_course_edit_page.application_open_from_year.value).to eq(valid_date_year)
  end

  def and_i_see_the_updated_send_specialism
    expect(support_course_edit_page.send_specialism_checkbox.checked?).to be true
  end

  def then_i_see_the_error_summary
    expect(support_course_edit_page.error_summary).to be_visible
  end

  def and_it_contains_invalid_value_errors
    expect(support_course_edit_page.error_summary.text).to include("Course code is already taken")
    expect(support_course_edit_page.error_summary.text).to include("October 2026 is not in the #{Settings.current_recruitment_cycle_year} cycle")
  end

  def and_it_contains_start_date_format_error
    expect(support_course_edit_page.error_summary.text).to include("Start date format is invalid")
  end

  def and_it_contains_applications_open_from_format_error
    expect(support_course_edit_page.error_summary.text).to include("Applications open from date format is invalid")
  end

  def and_it_contains_blank_errors
    expect(support_course_edit_page.error_summary.text).to include("Course code cannot be blank")
    expect(support_course_edit_page.error_summary.text).to include("Course title cannot be blank")
    expect(support_course_edit_page.error_summary.text).to include("Start date cannot have blank values")
    expect(support_course_edit_page.error_summary.text).to include("Select when applications will open and enter the date if applicable")
  end
end
