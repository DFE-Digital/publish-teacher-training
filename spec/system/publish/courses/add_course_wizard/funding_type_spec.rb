# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard funding type step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user_with_a_school
  end

  scenario "choosing a funding type and continues to courses index" do
    when_i_visit_the_wizard_funding_type_page
    and_i_choose_funding_type
    and_i_click_continue
    then_i_am_taken_to_the_courses_index_page
  end

  scenario "submitting funding type without selecting a funding type shows validation errors" do
    when_i_visit_the_wizard_funding_type_page
    and_i_click_continue
    then_i_have_errors_on_the_funding_type_step
  end

private

  def when_i_visit_the_wizard_funding_type_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :funding_type,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_funding_type
    choose "Fee - no salary"
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

  def then_i_have_errors_on_the_funding_type_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select a funding type")
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
