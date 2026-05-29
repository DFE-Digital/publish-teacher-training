# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard schools step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_multiple_schools
  end

  scenario "choosing a salaried school and continues to courses index page" do
    and_i_have_wizard_state_for_schools(funding_type: "salary")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "choosing a non-salaried school and continues to courses index page" do
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_the_title_and_description_are_displayed_for_a_non_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "submitting schools without selecting a school shows validation errors" do
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_have_errors_on_the_schools_step
  end

  scenario "single-school provider continues without explicitly selecting the only school" do
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_i_have_wizard_state_for_schools(funding_type: "fee")
    when_i_visit_the_wizard_schools_page
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "TDA qualification route continues through schools step to courses index" do
    and_i_have_wizard_state_for_qualifications(level: "primary")
    when_i_visit_the_wizard_qualifications_page
    and_i_choose_qualification("Teacher degree apprenticeship (TDA) with QTS")
    and_i_click_continue
    then_i_am_taken_to_the_schools_page
    and_the_title_and_description_are_displayed_for_a_salaried_school
    and_i_choose_a_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

private

  def when_i_visit_the_wizard_schools_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :schools,
      state_key: wizard_state_key,
    )
  end

  def when_i_visit_the_wizard_qualifications_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :qualifications,
      state_key: wizard_state_key,
    )
  end

  def and_the_title_and_description_are_displayed_for_a_salaried_school
    expect(page).to have_content("Employing schools")
    expect(page).to have_content("If you do not add all relevant employing schools, you may miss out on potential candidates.")
  end

  def and_the_title_and_description_are_displayed_for_a_non_salaried_school
    expect(page).to have_content("Placement schools")
    expect(page).to have_content("If you do not add all relevant placement schools, you may miss out on potential candidates.")
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_choose_qualification(qualification)
    choose qualification
  end

  def and_i_choose_a_site_from_the_list
    check provider.sites.first.location_name
  end

  def then_i_have_errors_on_the_schools_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select at least one school")
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

  def then_i_am_taken_to_the_schools_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :schools,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def given_i_am_authenticated_as_a_provider_user_with_multiple_schools
    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, sites: [build(:site), build(:site)]),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_provider_user_with_a_school
    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, sites: [build(:site)]),
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

  def and_i_have_wizard_state_for_schools(funding_type:)
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(funding_type:)
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
