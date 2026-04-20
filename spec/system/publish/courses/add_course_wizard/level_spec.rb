# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard level step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a primary level and no SEND and continues to subjects" do
    when_i_visit_the_wizard_level_page
    and_i_choose_primary_level
    and_i_choose_no_for_send_specialism
    and_i_click_continue
    then_i_go_back_to_the_school_courses_page
  end

  scenario "submitting without selecting a level or SEND shows validation errors" do
    when_i_visit_the_wizard_level_page
    and_i_click_continue
    then_i_have_errors_on_the_level_step
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

  def when_i_visit_the_wizard_level_page
    visit new_publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def and_i_choose_primary_level
    choose "Primary"
  end

  def and_i_choose_no_for_send_specialism
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_course_wizard_subjects_step
    expect(page).to have_current_path(
      new_publish_provider_recruitment_cycle_courses_subjects_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
      ),
    )
    expect(page).to have_content("Subject")
  end

  def then_i_go_back_to_the_school_courses_page
    expect(page).to have_current_path(publish_provider_recruitment_cycle_courses_path(provider.provider_code, provider.recruitment_cycle_year))
  end

  def then_i_have_errors_on_the_level_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a subject level")
    expect(page).to have_content("Select if this course has a special educational needs and disability (SEND) specialism")
  end

  def provider
    @provider ||= @user.providers.first
  end
end
