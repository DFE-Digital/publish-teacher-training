# frozen_string_literal: true

require "rails_helper"

feature "Entering a deadline for candidates who need visa sponsorship" do
  before do
    FeatureFlag.activate(:visa_sponsorship_deadline)
  end

  scenario "navigation" do
    given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_i_am_creating_a_new_course_that_allows_visa_sponsorship
    then_i_am_asked_if_there_is_a_different_deadline_for_candidates_with_visa_sponsorship

    when_i_go_back
    then_i_see_the_visa_sponsorship_question
    when_i_select_no_visa_sponsorship_and_continue
    then_i_am_on_the_applications_open_date_page

    when_i_go_back
    then_i_see_the_visa_sponsorship_question
    when_i_select_yes_visa_sponsorship_and_continue
    then_i_am_asked_if_there_is_a_different_deadline_for_candidates_with_visa_sponsorship

    when_i_select_no_deadline_and_continue
    then_i_am_on_the_applications_open_date_page
    when_i_go_back
    then_i_am_asked_if_there_is_a_different_deadline_for_candidates_with_visa_sponsorship
    when_i_select_yes_deadline_and_continue

    then_i_am_asked_for_the_date
    when_i_go_back
    then_i_am_asked_if_there_is_a_different_deadline_for_candidates_with_visa_sponsorship
  end

  scenario "errors" do
    given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_i_am_creating_a_new_course_that_allows_visa_sponsorship

    when_i_continue_without_selecting_whether_or_not_there_is_a_deadline
    then_i_see_an_error("Select if there is a deadline for applications that require visa sponsorship")

    when_i_select_yes_deadline_and_continue
    and_i_click_continue_without_adding_a_date
    then_i_see_an_error("Enter a date that applications close for visa sponsored candidates")

    when_i_enter_a_date_before_the_start_of_cycle
    then_i_see_the_out_of_range_error

    when_i_enter_a_date(@provider.recruitment_cycle_year, 2, 31)
    then_i_see_an_error("Enter a real date that applications close for visa sponsored candidates")

    when_i_enter_a_date(2021, 2, "")
    then_i_see_an_error("The date that applications which require visa sponsorship will close must contain a day, a month and a year")

    when_i_enter_a_date(2021, "", "")
    then_i_see_an_error("The date that applications which require visa sponsorship will close must contain a day, a month and a year")

    when_i_enter_a_date("", "2", 2)
    then_i_see_an_error("The date that applications which require visa sponsorship will close must contain a day, a month and a year")

    when_i_enter_a_date("year", "a", "14")
    then_i_see_an_error("The date that applications which require visa sponsorship will close can only contain numbers 0 to 9")

    when_i_enter_a_date("2025", "0", "14")
    then_i_see_an_error("Enter a real date that applications close for visa sponsored candidates")
  end

  scenario "changing my answers at the review page and saving with new date" do
    given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    and_i_am_creating_a_new_course_that_allows_visa_sponsorship
    when_i_select_no_deadline_and_continue
    and_i_complete_the_rest_of_the_form
    then_i_see_the_review_page_with_no_deadline_selected

    when_i_change_my_answer_to_yes_and_select_a_date

    then_i_see_the_review_page_with_the_deadline
    when_i_change_my_answer_back_to_no
    then_i_see_the_review_page_with_no_deadline_selected

    when_i_change_my_answer_to_yes_and_select_a_new_date
    when_i_add_the_course
    then_the_course_is_saved_with_the_new_deadline
  end

private

  def then_i_am_asked_if_there_is_a_different_deadline_for_candidates_with_visa_sponsorship
    expect(page).to have_content "Is there a deadline for applications that require visa sponsorship?"
  end

  def when_i_select_no_deadline_and_continue
    page.find_by_id("course-visa-sponsorship-application-deadline-required-field").click
    click_on_continue
  end

  def when_i_select_yes_deadline_and_continue
    choose "Yes"
    click_on_continue
  end

  def then_i_am_asked_for_the_date
    expect(page).to have_content("What date will applications that require visa sponsorship close?")
  end

  def when_i_go_back
    click_on "Back"
  end

  def then_i_see_the_visa_sponsorship_question
    expect(page).to have_content "Can your organisation sponsor Skilled Worker visas for this course?"
  end

  def when_i_select_no_visa_sponsorship_and_continue
    page.find_by_id("course_can_sponsor_skilled_worker_visa_false").click
    click_on_continue
  end

  def when_i_select_yes_visa_sponsorship_and_continue
    page.find_by_id("course_can_sponsor_skilled_worker_visa_true").click
    click_on_continue
  end

  def then_i_am_on_the_applications_open_date_page
    expect(page).to have_content "Applications open date"
  end

  def when_i_enter_a_date_before_the_start_of_cycle
    date = @provider.recruitment_cycle.application_start_date.end_of_day.change(hour: 9) - 1.day
    when_i_enter_a_date(date.year, date.month, date.day)
    click_on_continue
  end

  def then_i_see_the_out_of_range_error
    start_of_cycle = @provider.recruitment_cycle.application_start_date.end_of_day.change(hour: 9).to_fs(:govuk_date_and_time)
    end_of_cycle = @provider.recruitment_cycle.application_end_date.end_of_day.change(hour: 18).to_fs(:govuk_date_and_time)
    error_message = "The date that applications which require visa sponsorship will close must be between #{start_of_cycle} and the end of the recruitment cycle, #{end_of_cycle}"
    then_i_see_an_error(error_message)
  end

  def when_i_enter_a_date(year, month, day)
    fill_in "Year", with: year
    fill_in "Month", with: month
    fill_in "Day", with: day
    click_on_continue
  end

  def click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_continue_without_adding_a_date, :click_on_continue
  alias_method :when_i_continue_without_selecting_whether_or_not_there_is_a_deadline, :click_on_continue

  def then_i_see_an_error(error_message)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(error_message).twice
    expect(page.title).to have_text "Error:"
  end

  def then_i_see_the_review_page_with_no_deadline_selected
    expect(page).to have_content "Check your answers"
    expect(page).to have_content "Is there a visa sponsorship deadline?"
    expect(page).to have_content "No"
  end

  def then_i_see_the_review_page_with_the_deadline
    expect(page).to have_content "Check your answers"
    expect(page).to have_content "Is there a visa sponsorship deadline?"
    expect(page).to have_content "Yes"
    expect(page).to have_content "Visa sponsorship deadline"
    expect(page).to have_content @original_deadline_date.to_fs(:govuk_date)
  end

  def when_i_change_my_answer_to_yes_and_select_a_date
    click_on "Change visa sponsorship deadline required"
    choose "Yes"
    click_on_continue

    @original_deadline_date = @provider.recruitment_cycle.application_start_date.end_of_day.change(hour: 9) + 1.day
    fill_in "Day", with: @original_deadline_date.day
    fill_in "Month", with: @original_deadline_date.month
    fill_in "Year", with: @original_deadline_date.year
    click_on_continue
  end

  def when_i_change_my_answer_to_yes_and_select_a_new_date
    click_on "Change visa sponsorship deadline required"
    choose "Yes"
    click_on_continue

    @new_date = @provider.recruitment_cycle.application_start_date.end_of_day.change(hour: 9) + 10.days
    fill_in "Day", with: @new_date.day
    fill_in "Month", with: @new_date.month
    fill_in "Year", with: @new_date.year
    click_on_continue
  end

  def when_i_change_my_answer_back_to_no
    click_on "Change visa sponsorship deadline required"
    choose "No"
    click_on_continue
  end

  def when_i_add_the_course
    click_on "Add course"
  end

  def then_the_course_is_saved_with_the_new_deadline
    deadline = @provider.courses.reload.last.visa_sponsorship_application_deadline_at
    expect(deadline).to be_within(1.second).of @new_date.in_time_zone("London").end_of_day.utc
  end

  def and_i_complete_the_rest_of_the_form
    # Applications open date
    apply_opens = @provider.recruitment_cycle.application_start_date.to_fs(:govuk_date)
    choose "On #{apply_opens} when Apply opens - recommended"
    click_on_continue

    # Course start date
    choose "September #{@provider.recruitment_cycle_year}"
    click_on_continue
  end

  def and_i_am_creating_a_new_course_that_allows_visa_sponsorship
    visit new_publish_provider_recruitment_cycle_course_path(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
    )

    # Type of course and send
    choose "Primary"
    page.find_by_id("course_is_send_false").click
    click_on_continue

    # Subject
    choose "Primary"
    click_on_continue

    # Age range
    choose "5 to 11"
    click_on_continue

    # Qualification
    choose "QTS with PGCE"
    click_on_continue

    # Funding type
    choose "Salary"
    click_on_continue

    # Study pattern
    check "Full time"
    click_on_continue

    # Schools
    first("input[type='checkbox']").check
    click_on_continue

    # Study sites
    first("input[type='checkbox']").check
    click_on_continue

    # Visa sponsorship
    page.find_by_id("course_can_sponsor_skilled_worker_visa_true").click
    click_on_continue
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    @provider = create(:provider, :next_recruitment_cycle, :accredited_provider, sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end
end
