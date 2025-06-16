# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Confirm rollover", service: :publish do
  include DfESignInUserHelper
  let(:provider) { create(:provider) }
  let(:user) { create(:user, :admin, providers: [provider]) }
  let!(:current_recruitment_cycle) { create(:recruitment_cycle) }
  let!(:next_recruitment_cycle) { create(:recruitment_cycle, :next) }

  before do
    Timecop.travel(Time.zone.local(2025, 1, 1))

    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  scenario "when confirming the rollover to run" do
    given_i_visit_support_settings
    when_i_click_recruitment_cycles
    and_i_click_next_cycle

    when_i_click_to_review_rollover_information
    and_i_click_continue
    then_i_see_an_error_message
    and_i_write_the_wrong_confirmation_message
    and_i_click_continue
    then_i_see_an_error_message

    when_i_confirm_the_rollover
    and_i_click_continue
    then_rollover_is_started
  end

  def given_i_visit_support_settings
    visit support_settings_path
  end

  def when_i_click_recruitment_cycles
    click_link_or_button "Recruitment Cycles"
  end

  def and_i_click_next_cycle
    click_link_or_button next_recruitment_cycle.year
  end

  def when_i_click_to_review_rollover_information
    click_link_or_button "Review rollover"
  end

  def and_i_click_continue
    click_link_or_button "Continue"
  end

  def then_i_see_an_error_message
    expect(page).to have_content("You must type 'confirm rollover' to proceed.")
  end

  def and_i_write_the_wrong_confirmation_message
    fill_in "Type ‘confirm rollover’ to confirm that you want to proceed", with: "wrong message"
  end

  def when_i_confirm_the_rollover
    fill_in "Type ‘confirm rollover’ to confirm that you want to proceed", with: "confirm rollover"
  end

  def then_rollover_is_started
    expect(page).to have_content("Rollover started. This process may take up to 1 hour to complete.")

    rollover_job = ActiveJob::Base.queue_adapter.enqueued_jobs.find { |job| job["job_class"] == "RolloverJob" }
    expect(rollover_job).to be_present
    expect(rollover_job["arguments"]).to contain_exactly(next_recruitment_cycle.id)
  end
end
