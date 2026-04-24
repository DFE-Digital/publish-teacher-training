# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard subjects step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_primary_subjects_exist
    and_secondary_subjects_exist
  end

  scenario "choosing a primary subject and continues to courses index" do
    when_i_visit_the_wizard_subjects_page_for_primary
    and_i_choose_primary_subject
    and_i_click_continue
    then_i_am_taken_to_the_courses_page
  end

  scenario "submitting primary without selecting a subject shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_primary
    and_i_click_continue
    then_i_have_errors_on_the_subjects_step
  end

  scenario "choosing a secondary subject and continues to courses index" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_courses_page
  end

  scenario "submitting secondary without selecting a subject shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_click_continue
    then_i_have_errors_on_the_subjects_step
  end

private

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, sites: [build(:site)]),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def and_primary_subjects_exist
    primary_subject
  end

  def and_secondary_subjects_exist
    secondary_subject
  end

  def when_i_visit_the_wizard_subjects_page_for_primary
    visit new_publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
    )

    choose "Primary"
    choose "No"
    click_on "Continue"
  end

  def when_i_visit_the_wizard_subjects_page_for_secondary
    visit new_publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
    )

    choose "Secondary"
    choose "No"
    click_on "Continue"
  end

  def and_i_choose_primary_subject
    choose primary_subject.subject_name
  end

  def and_i_choose_secondary_subject
    select secondary_subject.subject_name, from: "First subject"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_courses_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_courses_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
      ),
      ignore_query: true,
    )
  end

  def then_i_have_errors_on_the_subjects_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject")
  end

  def primary_subject
    @primary_subject ||= find_or_create(:primary_subject, :primary_with_english)
  end

  def secondary_subject
    @secondary_subject ||= find_or_create(:secondary_subject, :business_studies)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
