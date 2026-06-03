# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard accredited provider step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_school_based_provider_user_with_multiple_accredited_partners
    and_i_have_wizard_state_for_accredited_provider
  end

  scenario "choosing an accredited provider and continues to visa sponsorship page" do
    when_i_visit_the_wizard_accredited_provider_page
    and_i_choose_an_accredited_provider
    and_i_click_continue
    then_i_am_taken_to_the_visa_sponsorship_page
  end

  scenario "submitting without selecting an accredited provider shows validation errors" do
    when_i_visit_the_wizard_accredited_provider_page
    and_i_click_continue
    then_i_have_errors_on_the_accredited_provider_step
  end

  scenario "shows accredited provider options" do
    when_i_visit_the_wizard_accredited_provider_page
    then_i_see_the_accredited_provider_page_content
  end

private

  def given_i_am_authenticated_as_a_school_based_provider_user_with_multiple_accredited_partners
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      sites: wizard_sites,
    )
    @accredited_partner_one = create(
      :accredited_provider,
      provider_name: "Middlesex University",
      recruitment_cycle: school_provider.recruitment_cycle,
    )
    @accredited_partner_two = create(
      :accredited_provider,
      provider_name: "University of Hertfordshire",
      recruitment_cycle: school_provider.recruitment_cycle,
    )
    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: @accredited_partner_one,
    )
    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: @accredited_partner_two,
    )

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_wizard_state_for_accredited_provider
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(level: "secondary")
  end

  def when_i_visit_the_wizard_accredited_provider_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :accredited_provider,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_an_accredited_provider
    choose @accredited_partner_one.provider_name
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

  def then_i_have_errors_on_the_accredited_provider_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select an accredited provider")
  end

  def then_i_see_the_accredited_provider_page_content
    expect(page).to have_content("Add course")
    expect(page).to have_content("Accredited provider")
    expect(page).to have_field(@accredited_partner_one.provider_name, type: "radio")
    expect(page).to have_field(@accredited_partner_two.provider_name, type: "radio")
    expect(page).to have_button("Continue")
  end

  def wizard_sites
    [
      build(:site),
      build(:site),
    ]
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
