# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard visa sponsorship application deadline at step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a visa sponsorship application deadline at and continues to start date page" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "submitting without selecting a visa sponsorship application deadline at shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(
      "Select a date that applications close for visa sponsored candidates",
    )
  end

  scenario "submitting with a date that is not in range shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_in_range
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(not_in_range_error_message)
  end

  scenario "submitting with a date that is not a valid date shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_a_valid_date
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(
      "Enter a real date that applications close for visa sponsored candidates",
    )
  end

  scenario "submitting with letters instead of numbers shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at_with_letters
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(
      "The date that applications which require visa sponsorship will close can only contain numbers 0 to 9",
    )
  end

  scenario "submitting with mixed letters and numbers shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at_with_mixed_values
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(
      "The date that applications which require visa sponsorship will close can only contain numbers 0 to 9",
    )
  end

  scenario "submitting with a date that is not within the recruitment cycle range shows validation errors" do
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_within_the_recruitment_cycle_range
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(not_in_range_error_message)
  end

private

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [create(:provider, :accredited_provider, can_sponsor_student_visa: true, sites: [build(:site)])],
    )

    given_i_am_authenticated(user: @user)
    and_i_have_wizard_state_for_visa_sponsorship_application_deadline_at
  end

  def and_i_have_wizard_state_for_visa_sponsorship_application_deadline_at
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    CourseWizard::StateStores::CourseWizardStore.new(repository:)
  end

  def when_i_visit_the_wizard_visa_sponsorship_application_deadline_at_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :visa_sponsorship_application_deadline_at,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at
    valid_date = Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_date - 1.day
    fill_in "Day", with: valid_date.day
    fill_in "Month", with: valid_date.month
    fill_in "Year", with: valid_date.year
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_in_range
    invalid_date = Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_date + 1.day
    fill_in "Day", with: invalid_date.day
    fill_in "Month", with: invalid_date.month
    fill_in "Year", with: invalid_date.year
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_a_valid_date
    fill_in "Day", with: 31
    fill_in "Month", with: 2
    fill_in "Year", with: provider.recruitment_cycle_year
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at_with_letters
    fill_in "Day", with: "ab"
    fill_in "Month", with: "cd"
    fill_in "Year", with: "efgh"
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at_with_mixed_values
    fill_in "Day", with: "1a"
    fill_in "Month", with: "2"
    fill_in "Year", with: provider.recruitment_cycle_year
  end

  def and_i_choose_a_visa_sponsorship_application_deadline_at_that_is_not_within_the_recruitment_cycle_range
    fill_in "Day", with: 1
    fill_in "Month", with: 1
    fill_in "Year", with: 2000
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_start_date_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :start_date,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_have_errors_on_the_visa_sponsorship_application_deadline_at_step(error_message)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(error_message)
  end

  def not_in_range_error_message
    apply_deadline = Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_fs(:govuk_date_and_time)
    start_of_cycle = provider.recruitment_cycle.application_start_date.change(hour: 9)
    earliest_date = Time.zone.now.after?(start_of_cycle) ? "today" : start_of_cycle.to_fs(:govuk_date_and_time)

    "The date that applications which require visa sponsorship will close must be between #{earliest_date} and the end of the recruitment cycle, #{apply_deadline}"
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
