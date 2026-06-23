# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard start date step when qualification is undergraduate degree with qts", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user(cycle_year: Date.current.year)
  end

  scenario "choosing a start date and continues to check answers" do
    and_i_have_wizard_state_for_start_date
    when_i_visit_the_wizard_start_date_page
    and_i_choose_a_start_date(current_cycle_current_month_label(cycle_year: Date.current.year))
    and_i_click_continue
    then_i_am_taken_to_the_check_answers_page
  end

  scenario "submitting start date without selecting an option shows validation errors" do
    and_i_have_wizard_state_for_start_date
    when_i_visit_the_wizard_start_date_page
    and_i_click_continue
    then_i_have_errors_on_the_start_date_step
  end

  scenario "shows options from the current month when in the recruitment cycle year" do
    and_i_have_wizard_state_for_start_date
    when_i_visit_the_wizard_start_date_page

    expect(page).to have_content("Course start date")
    expect(page).to have_field(current_cycle_current_month_label(cycle_year: Date.current.year))
    expect(page).to have_field("July #{Date.current.year + 1}")
    expect(page).not_to have_field(previous_month_label(cycle_year: Date.current.year)) if Date.current.month > 1
  end

  scenario "shows options starting from January when provider recruitment cycle is in the future" do
    given_i_am_authenticated_as_a_provider_user(cycle_year: Date.current.year + 1)
    and_i_have_wizard_state_for_start_date
    when_i_visit_the_wizard_start_date_page

    expect(page).to have_content("Course start date")
    expect(page).to have_field("January #{Date.current.year + 1}")
    expect(page).not_to have_field("December #{Date.current.year}")
    expect(page).to have_field("July #{Date.current.year + 2}")
  end

private

  def when_i_visit_the_wizard_start_date_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :start_date,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_a_start_date(start_date)
    choose start_date
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_check_answers_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :check_answers,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
    expect(page).to have_content("Check your answers")
  end

  def and_i_click_add_course
    click_on "Add course"
  end

  def then_i_have_errors_on_the_start_date_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a course start date")
  end

  def given_i_am_authenticated_as_a_provider_user(cycle_year:)
    recruitment_cycle = find_or_create(:recruitment_cycle, year: cycle_year)

    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, recruitment_cycle:),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

  def current_cycle_current_month_label(cycle_year:)
    "#{Date::MONTHNAMES[Date.current.month]} #{cycle_year}"
  end

  def previous_month_label(cycle_year:)
    "#{Date::MONTHNAMES[Date.current.month - 1]} #{cycle_year}"
  end

  def and_i_have_wizard_state_for_start_date
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      qualification: "undergraduate_degree_with_qts",
    )
  end
end
