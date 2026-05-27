# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard study pattern step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a study pattern and continues to courses index" do
    when_i_visit_the_wizard_study_pattern_page
    and_i_choose_study_pattern
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "submitting study pattern without selecting a study pattern shows validation errors" do
    when_i_visit_the_wizard_study_pattern_page
    and_i_click_continue
    then_i_have_errors_on_the_study_pattern_step
  end

private

  def when_i_visit_the_wizard_study_pattern_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :study_pattern,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_study_pattern
    check "Full time"
    check "Part time"
  end

  def and_i_click_continue
    click_on "Continue"
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

  def then_i_have_errors_on_the_study_pattern_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a study pattern")
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
end
