# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard age range step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
    and_primary_subjects_exist
    and_secondary_subjects_exist
  end

  scenario "choosing a primary age range and continues to courses index" do
    when_i_visit_the_wizard_subjects_page_for_primary
    and_i_choose_primary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_primary_age_range
    and_i_click_continue
    then_i_am_taken_to_the_courses_page
  end

  scenario "choosing a secondary age range and continues to courses index" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_secondary_age_range
    and_i_click_continue
    then_i_am_taken_to_the_courses_page
  end

  scenario "choosing no age_range_in_years options renders an error" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_click_continue
    then_i_should_see_an_error_message
  end

  scenario "choosing other and submitting blank from and to ages shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_other_age_range
    and_i_click_continue
    then_i_should_see_missing_other_age_range_errors
  end

  scenario "choosing other with non-numeric ages shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_other_age_range
    and_i_fill_in_other_age_range(from: "abc", to: "11")
    and_i_click_continue
    then_i_should_see_invalid_other_from_age_error
  end

  scenario "choosing other with an out-of-bounds age range shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_other_age_range
    and_i_fill_in_other_age_range(from: "2", to: "11")
    and_i_click_continue
    then_i_should_see_other_from_age_bounds_error
  end

  scenario "choosing other with a range shorter than four years shows validation errors" do
    when_i_visit_the_wizard_subjects_page_for_secondary
    and_i_choose_secondary_subject
    and_i_click_continue
    then_i_am_taken_to_the_age_range_page
    and_i_choose_other_age_range
    and_i_fill_in_other_age_range(from: "8", to: "11")
    and_i_click_continue
    then_i_should_see_age_span_minimum_years_error
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

  def then_i_should_see_an_error_message
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select an age range")
  end

  def then_i_should_see_missing_other_age_range_errors
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Enter an age in From")
    expect(page).to have_content("Enter an age in To")
  end

  def then_i_should_see_invalid_other_from_age_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Enter a valid age in From")
  end

  def then_i_should_see_age_span_school_years_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Age range must cover 4 or more school years")
  end

  def then_i_should_see_other_from_age_bounds_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("From age must be between 3 and 15")
  end

  def then_i_should_see_age_span_minimum_years_error
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Age range must cover at least 4 years")
  end

  def then_i_am_taken_to_the_age_range_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :age_range,
        state_key: wizard_state_key,
      ),
    )

    expect(page).to have_content("Age range")
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

  def and_i_choose_primary_subject
    choose primary_subject.subject_name
  end

  def and_i_choose_primary_age_range
    choose "3 to 7"
  end

  def and_i_choose_secondary_subject
    select secondary_subject.subject_name, from: "First subject"
  end

  def and_i_choose_secondary_age_range
    choose "11 to 16"
  end

  def and_i_choose_other_age_range
    choose "Another age range"
  end

  def and_i_fill_in_other_age_range(from:, to:)
    fill_in "From", with: from
    fill_in "To", with: to
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def primary_subject
    @primary_subject ||= find_or_create(:primary_subject, :primary_with_english)
  end

  def secondary_subject
    @secondary_subject ||= find_or_create(:secondary_subject, :business_studies)
  end

  def and_primary_subjects_exist
    primary_subject
  end

  def and_secondary_subjects_exist
    secondary_subject
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
