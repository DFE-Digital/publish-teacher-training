# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard level step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a primary level and no SEND and continues to primary subjects" do
    when_i_visit_the_wizard_level_page
    and_i_choose_primary_level
    and_i_choose_no_for_send_specialism
    and_i_click_continue
    then_i_am_taken_to_the_primary_subjects_page
  end

  scenario "choosing a secondary level and no SEND and continues to secondary subjects" do
    when_i_visit_the_wizard_level_page
    and_i_choose_secondary_level
    and_i_choose_no_for_send_specialism
    and_i_click_continue
    then_i_am_taken_to_the_secondary_subjects_page
  end

  scenario "submitting without selecting a level or SEND shows validation errors" do
    when_i_visit_the_wizard_level_page
    and_i_click_continue
    then_i_have_errors_on_the_level_step
  end

  scenario "provider after the school remodel cycle cannot start with a site school" do
    given_i_am_authenticated_as_a_provider_user_without_a_site_school
    when_i_visit_the_wizard_level_page
    then_i_see_the_no_school_error
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

  def given_i_am_authenticated_as_a_provider_user_without_a_site_school
    recruitment_cycle = find_or_create(:recruitment_cycle, year: Settings.schools_remodel_cycle_year + 1)
    provider = create(:provider, :accredited_provider, recruitment_cycle:)
    create(:provider_school, provider:)

    @user = create(:user, providers: [provider])

    given_i_am_authenticated(user: @user)
  end

  def when_i_visit_the_wizard_level_page
    visit new_publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_primary_level
    choose "Primary"
  end

  def and_i_choose_secondary_level
    choose "Secondary"
  end

  def and_i_choose_no_for_send_specialism
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_primary_subjects_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :primary_subjects,
        state_key: wizard_state_key,
      ),
    )
    expect(page).to have_content("Subject")
  end

  def then_i_am_taken_to_the_secondary_subjects_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :secondary_subjects,
        state_key: wizard_state_key,
      ),
    )
    expect(page).to have_content("Subject")
  end

  def then_i_have_errors_on_the_level_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject level")
    expect(page).to have_content("Select if this course has a special educational needs and disability (SEND) specialism")
  end

  def then_i_see_the_no_school_error
    expect(page).to have_content("You need to create at least one school before creating a course")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
