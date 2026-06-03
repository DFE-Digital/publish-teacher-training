# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard study sites step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_multiple_schools
  end

  scenario "choosing a study site and continues to visa sponsorship page when qualification is not TDA or further education" do
    when_i_visit_the_wizard_study_sites_page
    and_i_choose_a_study_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_visa_sponsorship_page
  end

  scenario "choosing a study site and continues to start date page when qualification is TDA" do
    and_i_have_wizard_state_for_study_sites(qualification: "undergraduate_degree_with_qts")
    when_i_visit_the_wizard_study_sites_page
    and_i_choose_a_study_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "choosing a study site and continues to start date page when level is further education" do
    and_i_have_wizard_state_for_study_sites(level: "further_education")
    when_i_visit_the_wizard_study_sites_page
    and_i_choose_a_study_site_from_the_list
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

private

  def when_i_visit_the_wizard_study_sites_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :study_sites,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_a_study_site_from_the_list
    check provider.study_sites.first.location_name
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_visa_sponsorship_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :visa_sponsorship,
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

  def given_i_am_authenticated_as_a_provider_user_with_multiple_schools
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          sites: [
            build(:site),
            build(:site),
            build(:site, :study_site),
            build(:site, :study_site),
          ],
        ),
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

  def and_i_have_wizard_state_for_study_sites(qualification: nil, level: nil)
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(qualification:, level:)
  end
end
