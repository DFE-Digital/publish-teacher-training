# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard skilled worker visa step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing yes to skilled worker visa and continues to courses index" do
    when_i_visit_the_wizard_skilled_worker_visa_page
    and_i_choose_yes_to_the_skilled_worker_visa_question
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "choosing no to skilled worker visa and continues to start date page" do
    when_i_visit_the_wizard_skilled_worker_visa_page
    and_i_choose_no_to_the_skilled_worker_visa_question
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "choosing nil to skilled worker visa and shows validation errors" do
    when_i_visit_the_wizard_skilled_worker_visa_page
    and_i_click_continue
    then_i_have_errors_on_the_skilled_worker_visa_step
  end

private

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [create(:provider, :accredited_provider, sites: [build(:site)])],
    )

    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_wizard_skilled_worker_visa_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :skilled_worker_visa,
      state_key: wizard_state_key,
    )

    expect(page).to have_content("Can your organisation sponsor Skilled Worker visas for this course?")
  end

  def then_i_have_errors_on_the_skilled_worker_visa_step
    expect(page).to have_content("Select if candidates can get a sponsored Skilled Worker visa")
  end

  def and_i_choose_yes_to_the_skilled_worker_visa_question
    choose "Yes"
  end

  def and_i_choose_no_to_the_skilled_worker_visa_question
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_start_date_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_course_wizard_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, step: :start_date, state_key: wizard_state_key))
  end

  def then_i_am_taken_to_the_courses_index_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_courses_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year))
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
