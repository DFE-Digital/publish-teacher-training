# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard check answers step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_i_have_wizard_state_for_check_answers
  end

  scenario "shows the check your answers page and creates the course flow" do
    when_i_visit_the_wizard_check_answers_page

    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Subject level")
    expect(page).to have_content("Primary")
    expect(page).to have_content("SEND specialism")
    expect(page).to have_content("Yes")
    expect(page).to have_content("Course start date")
    expect(page).to have_button("Create course")

    and_i_click_create_course
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "returns to check answers when editing via a change link" do
    when_i_visit_the_wizard_check_answers_page
    and_i_click_change_for_start_date
    and_i_choose_a_start_date
    and_i_click_continue

    then_i_am_taken_back_to_the_check_answers_page
  end

  scenario "shows the only accredited provider when selection is not required" do
    given_i_am_authenticated_as_a_school_based_provider_user_with_one_accredited_partner
    and_i_have_wizard_state_for_check_answers

    when_i_visit_the_wizard_check_answers_page

    expect(page).to have_content("Accredited provider")
    expect(page).to have_content(@accrediting_provider.provider_name)
  end

private

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [create(:provider, :accredited_provider, sites: [build(:site)])],
    )

    given_i_am_authenticated(user: @user)
  end

  def and_i_have_wizard_state_for_check_answers
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      is_send: "true",
      primary_master_subject_id: Subject.primary.first.id,
      age_range_in_years: "3_to_7",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [provider.sites.first.id],
      can_sponsor_student_visa: false,
      start_date: "January #{provider.recruitment_cycle_year}",
    )
  end

  def given_i_am_authenticated_as_a_school_based_provider_user_with_one_accredited_partner
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      can_sponsor_student_visa: false,
      sites: [build(:site)],
    )

    @accrediting_provider = create(
      :accredited_provider,
      recruitment_cycle: school_provider.recruitment_cycle,
    )

    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: @accrediting_provider,
    )

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_wizard_check_answers_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :check_answers,
      state_key: wizard_state_key,
    )
  end

  def and_i_click_change_for_start_date
    click_on "Change course start date"
  end

  def and_i_choose_a_start_date
    choose "January #{provider.recruitment_cycle_year}"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_click_create_course
    click_on "Create course"
  end

  def then_i_am_taken_to_the_courses_index_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_courses_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_back_to_the_check_answers_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :check_answers,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
