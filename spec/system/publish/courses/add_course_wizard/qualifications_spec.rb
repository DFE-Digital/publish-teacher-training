# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard qualifications step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a qualification with primary level and continues to funding type page" do
    and_i_have_wizard_state_for_qualifications(level: "primary")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification(qualification: "QTS")
    and_i_click_continue
    then_i_am_taken_to_the_funding_type_page
  end

  scenario "choosing a qualification with secondary level and continues to funding type page" do
    and_i_have_wizard_state_for_qualifications(level: "secondary")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification(qualification: "QTS")
    and_i_click_continue
    then_i_am_taken_to_the_funding_type_page
  end

  scenario "choosing a qualification with further education level and continues to funding type page" do
    and_i_have_wizard_state_for_qualifications(level: "further_education")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification(qualification: "PGDE only (without QTS)")
    and_i_click_continue
    then_i_am_taken_to_the_funding_type_page
  end

  scenario "submitting qualifications without selecting a qualification shows validation errors" do
    and_i_have_wizard_state_for_qualifications(level: "primary")
    when_i_visit_the_wizard_qualifications_page
    and_i_click_continue
    then_i_have_errors_on_the_qualifications_step
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

  def when_i_visit_the_wizard_qualifications_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :qualifications,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_qualification(qualification:)
    choose qualification
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_funding_type_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :funding_type,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_have_errors_on_the_qualifications_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a qualification")
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

  def and_i_have_wizard_state_for_qualifications(level:)
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(level:)
  end
end
