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
    then_i_am_taken_to_the_age_range_page
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
    then_i_am_taken_to_the_age_range_page
  end

  scenario "submitting secondary without selecting a subject shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_click_continue
    then_i_have_errors_on_the_subjects_step
  end

  scenario "secondary subjects page shows bursary and scholarship link for the recruitment cycle", travel: mid_cycle(2026) do
    when_i_visit_the_wizard_subjects_page_for_secondary
    then_i_see_the_bursary_and_scholarship_link_for_the_recruitment_cycle
  end

  scenario "submitting secondary with a duplicate master and subordinate subject shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_duplicate_master_and_subordinate_subject
    and_i_click_continue
    then_i_should_see_a_duplicate_master_and_subordinate_subject_error
  end

  scenario "physics and modern languages selections show both specialism pages before age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :physics, subordinate: :modern_languages)
    when_i_visit_the_wizard_step(:physics_specialisms)
    then_i_am_taken_to_the_physics_specialisms_page

    and_i_select_engineers_teach_physics_option
    and_i_click_continue
    then_i_am_taken_to_the_modern_languages_specialisms_page

    and_i_select_a_modern_language
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "physics only selection shows physics specialisms then age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :physics)
    when_i_visit_the_wizard_step(:physics_specialisms)
    then_i_am_taken_to_the_physics_specialisms_page

    and_i_select_engineers_teach_physics_option
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "modern languages only selection shows modern languages specialisms then age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :modern_languages)
    when_i_visit_the_wizard_step(:modern_languages_specialisms)
    then_i_am_taken_to_the_modern_languages_specialisms_page

    and_i_select_a_modern_language
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "design technology only selection shows design technology specialisms then age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :design_and_technology)
    when_i_visit_the_wizard_step(:design_technology_specialisms)
    then_i_am_taken_to_the_design_technology_specialisms_page

    and_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "modern languages and design technology selections show both specialism pages before age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :modern_languages, subordinate: :design_and_technology)
    when_i_visit_the_wizard_step(:modern_languages_specialisms)
    then_i_am_taken_to_the_modern_languages_specialisms_page

    and_i_select_a_modern_language
    and_i_click_continue
    then_i_am_taken_to_the_design_technology_specialisms_page

    and_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "physics and design technology selections show both specialism pages before age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :physics, subordinate: :design_and_technology)
    when_i_visit_the_wizard_step(:physics_specialisms)
    then_i_am_taken_to_the_physics_specialisms_page

    and_i_select_engineers_teach_physics_option
    and_i_click_continue
    then_i_am_taken_to_the_design_technology_specialisms_page

    and_i_select_a_design_technology_specialism
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
  end

  scenario "modern languages other selection shows modern languages specialisms then age range" do
    and_i_have_wizard_state_for_specialism_flow(master: :modern_languages_other)
    when_i_visit_the_wizard_step(:modern_languages_specialisms)
    then_i_am_taken_to_the_modern_languages_specialisms_page

    and_i_select_a_modern_language
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
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

  def and_i_choose_duplicate_master_and_subordinate_subject
    select secondary_subject.subject_name, from: "First subject"
    select secondary_subject.subject_name, from: "Second subject"
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

  def when_i_visit_the_wizard_step(step_name)
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: step_name,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_primary_subject
    choose primary_subject.subject_name
  end

  def and_i_choose_secondary_subject
    select secondary_subject.subject_name, from: "First subject"
  end

  def and_i_choose_secondary_subject_pair(first:, second:)
    select first, from: "First subject"
    select second, from: "Second subject (optional)"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_age_range_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        step: :age_range,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_physics_specialisms_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        step: :physics_specialisms,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_modern_languages_specialisms_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        step: :modern_languages_specialisms,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_design_technology_specialisms_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        step: :design_technology_specialisms,
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def and_i_select_engineers_teach_physics_option
    choose "Yes"
  end

  def and_i_select_a_modern_language
    page.find(".govuk-checkboxes__input", visible: :all, match: :first).set(true)
  end

  def and_i_select_a_design_technology_specialism
    page.find(".govuk-checkboxes__input", visible: :all, match: :first).set(true)
  end

  def and_i_have_wizard_state_for_specialism_flow(master:, subordinate: nil)
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "secondary",
      secondary_master_subject_id: course_subject(master).id.to_s,
      subordinate_subject_id: subordinate.present? ? course_subject(subordinate).id.to_s : nil,
    )
  end

  def then_i_have_errors_on_the_subjects_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject")
  end

  def then_i_should_see_a_duplicate_master_and_subordinate_subject_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("The second subject must be different to the first subject")
  end

  def then_i_see_the_bursary_and_scholarship_link_for_the_recruitment_cycle
    expect(page).to have_link(
      "Learn more about the bursaries and scholarships",
      href: "https://www.gov.uk/government/publications/funding-initial-teacher-training-itt/funding-initial-teacher-training-itt-academic-year-2026-to-2027#postgraduate-bursaries-and-scholarships",
    )
  end

  def primary_subject
    @primary_subject ||= find_or_create(:primary_subject, :primary_with_english)
  end

  def secondary_subject
    @secondary_subject ||= find_or_create(:secondary_subject, :business_studies)
  end

  def course_subject(subject_key)
    case subject_key
    when :physics
      find_or_create(:secondary_subject, :physics)
    when :modern_languages
      find_or_create(:secondary_subject, :modern_languages)
    when :modern_languages_other
      find_or_create(:modern_languages_subject, :modern_languages_other)
    when :design_and_technology
      find_or_create(:secondary_subject, :design_and_technology)
    else
      raise "Unknown subject key: #{subject_key}"
    end
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
