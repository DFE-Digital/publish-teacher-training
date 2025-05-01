# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Adding a new recruitment cycle", service: :publish do
  include DfESignInUserHelper
  let(:provider) { create(:provider) }
  let(:user) { create(:user, :admin, providers: [provider]) }

  before do
    Timecop.travel(Time.zone.local(2025, 1, 1))

    driven_by(:rack_test)
    sign_in_system_test(user:)
  end

  scenario "add a recruitment cycle" do
    given_i_visit_support_settings
    when_i_click_recruitment_cycles
    and_i_click_add_recruitment_cycle
    and_i_submit_without_filling_in_the_form
    then_i_see_error_messages_for_missing_fields
    when_i_fill_in_valid_recruitment_cycle_details
    and_i_submit_the_form
    then_i_see_the_success_message
    and_the_recruitment_cycle_is_created
  end

  def given_i_visit_support_settings
    visit support_settings_path
  end

  def when_i_click_recruitment_cycles
    click_link_or_button "Recruitment Cycles"
  end

  def and_i_click_add_recruitment_cycle
    click_link_or_button "Add recruitment cycle"
  end

  def and_i_submit_without_filling_in_the_form
    click_link_or_button "Continue"
  end

  def then_i_see_error_messages_for_missing_fields
    expect(page).to have_text("There is a problem")
    expect(page).to have_text("Enter a year")
    expect(page).to have_text("Enter an application start date")
    expect(page).to have_text("Enter an application end date")
    expect(page).to have_text("Enter the date when courses will become available to users in Publish")
  end

  def when_i_fill_in_valid_recruitment_cycle_details
    fill_in "Recruitment cycle year", with: "2026"
    fill_in "support_recruitment_cycle_form[application_start_date(3i)]", with: "04"
    fill_in "support_recruitment_cycle_form[application_start_date(2i)]", with: "10"
    fill_in "support_recruitment_cycle_form[application_start_date(1i)]", with: "2025"
    fill_in "support_recruitment_cycle_form[application_end_date(3i)]", with: "04"
    fill_in "support_recruitment_cycle_form[application_end_date(2i)]", with: "10"
    fill_in "support_recruitment_cycle_form[application_end_date(1i)]", with: "2026"

    fill_in "support_recruitment_cycle_form[available_in_publish_from(3i)]", with: "04"
    fill_in "support_recruitment_cycle_form[available_in_publish_from(2i)]", with: "09"
    fill_in "support_recruitment_cycle_form[available_in_publish_from(1i)]", with: "2025"
  end

  def and_i_submit_the_form
    click_link_or_button "Continue"
  end

  def then_i_see_the_success_message
    expect(page).to have_text("Recruitment cycle added")
  end

  def and_the_recruitment_cycle_is_created
    recruitment_cycle = RecruitmentCycle.find_by(year: "2026")
    expect(recruitment_cycle).to be_present

    expect(recruitment_cycle.application_start_date).to eq(Date.new(2025, 10, 4))
    expect(recruitment_cycle.application_end_date).to eq(Date.new(2026, 10, 4))
    expect(recruitment_cycle.available_in_publish_from).to eq(Date.new(2025, 9, 4))
  end
end
