# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard changing funding type from check answers", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "changing salary to fee asks only the student visa question, then returns to check answers" do
    given_i_have_completed_a_salaried_course_without_visa_sponsorship
    when_i_visit_check_answers_page
    and_i_click_change_funding_type
    then_i_am_on_the_funding_type_page

    when_i_choose_fee
    and_i_click_continue
    then_i_am_on_the_student_visa_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_check_answers_page
  end

private

  def given_i_am_authenticated_as_a_provider_user
    recruitment_cycle = find_or_create(:recruitment_cycle, year: Find::CycleTimetable.current_year)
    @user = create(:user, providers: [create(:provider, :accredited_provider, recruitment_cycle:)])

    given_i_am_authenticated(user: @user)
  end

  def given_i_have_completed_a_salaried_course_without_visa_sponsorship
    placement_site = create(:site, :with_provider_school, provider:)
    study_site = create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    CourseWizard::StateStores::CourseWizardStore.new(repository:).write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: find_or_create(:secondary_subject, :mathematics).id.to_s,
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "salary",
      study_pattern: %w[full_time],
      school_uuids: [placement_site.uuid],
      study_sites_ids: [study_site.id.to_s],
      can_sponsor_skilled_worker_visa: false,
      start_date: "#{Date::MONTHNAMES[Date.current.month]} #{Find::CycleTimetable.current_year}",
    )
  end

  def when_i_visit_check_answers_page
    visit wizard_step_path(:check_answers)
  end

  def and_i_click_change_funding_type
    click_on "Change funding type"
  end

  def then_i_am_on_the_funding_type_page
    expect(page).to have_current_path(wizard_step_path(:funding_type), ignore_query: false)
  end

  def when_i_choose_fee
    choose "Fee - no salary"
  end

  def then_i_am_on_the_student_visa_page
    expect(page).to have_current_path(wizard_step_path(:visa_sponsorship), ignore_query: false)
  end

  def when_i_choose_no
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_on_the_check_answers_page
    expect(page).to have_content("Check your answers")
  end

  def wizard_step_path(step)
    publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step:,
      state_key: wizard_state_key,
    )
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
