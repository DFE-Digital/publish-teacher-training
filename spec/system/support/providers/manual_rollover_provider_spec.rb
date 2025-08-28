# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Manual provider rollover", service: :publish do
  include DfESignInUserHelper

  let(:provider) { create(:provider, recruitment_cycle: current_recruitment_cycle) }
  let(:user) { create(:user, :admin, providers: [provider]) }
  let!(:current_recruitment_cycle) { RecruitmentCycle.current }
  let!(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }

  before do
    Timecop.travel(Time.zone.local(2025, 1, 1))
    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  scenario "when manually rolling over a provider" do
    given_i_visit_the_provider_page
    when_i_click_rollover_provider_tab
    then_i_see_the_rollover_confirmation_page
    when_i_submit_without_confirmation
    then_i_see_validation_errors
    when_i_enter_wrong_confirmation_text
    and_i_enter_wrong_environment_name
    and_i_click_continue
    then_i_see_validation_errors
    when_i_enter_correct_confirmation_details
    and_i_click_continue
    then_the_provider_is_rolled_over_successfully
  end

  def given_i_visit_the_provider_page
    visit support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider)
  end

  def when_i_click_rollover_provider_tab
    click_link_or_button "Rollover provider"
  end

  def then_i_see_the_rollover_confirmation_page
    expect(page).to have_current_path(
      manual_rollover_support_recruitment_cycle_provider_path(
        provider.recruitment_cycle_year,
        provider,
      ),
    )
  end

  def when_i_submit_without_confirmation
    click_link_or_button "Continue"
  end

  def then_i_see_validation_errors
    expect(page).to have_content("You must type 'confirm manual rollover' to proceed")
    expect(page).to have_content("You must type the environment name to proceed")
  end

  def when_i_enter_wrong_confirmation_text
    fill_in "Type ‘confirm manual rollover’ to confirm that you want to proceed", with: "wrong text"
  end

  def and_i_enter_wrong_environment_name
    fill_in "Type ‘test’ to confirm that you want to proceed", with: "wrong environment"
  end

  def and_i_click_continue
    click_link_or_button "Continue"
  end

  def when_i_enter_correct_confirmation_details
    fill_in "Type ‘confirm manual rollover’ to confirm that you want to proceed", with: "confirm manual rollover"
    fill_in "Type ‘test’ to confirm that you want to proceed", with: "test"
  end

  def then_the_provider_is_rolled_over_successfully
    expect(page).to have_content("Provider successfully rolled over to the next recruitment cycle.")
    expect(page).to have_current_path(support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider), ignore_query: true)

    rolled_over_provider = next_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)
    expect(rolled_over_provider).to be_present
    expect(rolled_over_provider.recruitment_cycle).to eq(next_recruitment_cycle)
  end
end
