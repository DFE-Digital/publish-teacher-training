# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard visa sponsorship application deadline required step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing yes to visa sponsorship application deadline required and continues to visa sponsorship application deadline at page" do
    and_i_have_wizard_state_for_visa_sponsorship_application_deadline_required
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_required_page
    and_i_choose_yes_to_the_visa_sponsorship_application_deadline_required_question
    and_i_click_continue
    then_i_am_taken_to_the_visa_sponsorship_application_deadline_at_page
  end

  scenario "choosing no to visa sponsorship application deadline required and continues to start date page" do
    and_i_have_wizard_state_for_visa_sponsorship_application_deadline_required
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_required_page
    and_i_choose_no_to_the_visa_sponsorship_application_deadline_required_question
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "choosing nil to visa sponsorship application deadline required and shows validation errors" do
    and_i_have_wizard_state_for_visa_sponsorship_application_deadline_required
    when_i_visit_the_wizard_visa_sponsorship_application_deadline_required_page
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_application_deadline_required_step
  end

private

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(:user, providers: [create(:provider, :accredited_provider, sites: [build(:site)])])

    given_i_am_authenticated(user: @user)
  end

  def and_i_have_wizard_state_for_visa_sponsorship_application_deadline_required
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    CourseWizard::StateStores::CourseWizardStore.new(repository:)
  end

  def when_i_visit_the_wizard_visa_sponsorship_application_deadline_required_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :visa_sponsorship_application_deadline_required,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_yes_to_the_visa_sponsorship_application_deadline_required_question
    choose "Yes"
  end

  def and_i_choose_no_to_the_visa_sponsorship_application_deadline_required_question
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_visa_sponsorship_application_deadline_at_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :visa_sponsorship_application_deadline_at,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
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

  def then_i_have_errors_on_the_visa_sponsorship_application_deadline_required_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select if there is a deadline for applications that require visa sponsorship")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
