# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Editing a recruitment cycle", service: :publish, travel: mid_cycle(2025) do
  include DfESignInUserHelper
  let(:provider) { create(:provider) }
  let(:user) { create(:user, :admin, providers: [provider]) }

  before do
    sign_in_system_test(user:)

    given_there_are_recruitment_cycles
  end

  scenario "add a recruitment cycle" do
    given_i_visit_support_settings
    when_i_click_recruitment_cycles
    and_i_click_on_previous_cycle
    then_i_can_not_edit_the_cycle

    when_i_click_back
    and_i_click_on_current_cycle
    then_i_can_not_edit_the_cycle

    when_i_click_back
    and_i_click_on_upcoming_cycle
    then_i_can_edit_the_cycle

    when_i_click_change
    and_i_change_the_application_start_date
    and_i_change_the_application_end_date
    and_i_change_the_available_in_publish_from_date
    and_i_click_continue

    then_i_see_the_recruitment_cycle_updated_successfully
  end

  def given_there_are_recruitment_cycles
    @previous_cycle = find_or_create(:recruitment_cycle, :previous)
    @current_cycle = RecruitmentCycle.current
    @upcoming_cycle = find_or_create(:recruitment_cycle, :next)
  end

  def given_i_visit_support_settings
    visit support_settings_path
  end

  def when_i_click_recruitment_cycles
    click_link_or_button "Recruitment Cycles"
  end

  def and_i_click_on_previous_cycle
    click_link_or_button @previous_cycle.year
  end

  def then_i_can_not_edit_the_cycle
    expect(page).not_to have_content("Change")
  end

  def when_i_click_back
    click_link_or_button "Back"
  end

  def and_i_click_on_current_cycle
    click_link_or_button @current_cycle.year
  end

  def and_i_click_on_upcoming_cycle
    click_link_or_button @upcoming_cycle.year
  end

  def then_i_can_edit_the_cycle
    expect(page).to have_content("Change")
  end

  def when_i_click_change
    click_link_or_button "Change", match: :first
  end

  def and_i_change_the_application_start_date
    within_fieldset "Application start date" do
      fill_in "Day", with: "27"
      fill_in "Month", with: "09"
    end
  end

  def and_i_change_the_application_end_date
    within_fieldset "Application end date" do
      fill_in "Day", with: "05"
      fill_in "Month", with: "10"
    end
  end

  def and_i_change_the_available_in_publish_from_date
    within_fieldset "Available in Publish from" do
      fill_in "Day", with: RecruitmentCycle.current.available_for_support_users_from.succ.day
      fill_in "Month", with: RecruitmentCycle.current.available_for_support_users_from.succ.month
    end
  end

  def and_i_click_continue
    click_link_or_button "Continue"
  end

  def then_i_see_the_recruitment_cycle_updated_successfully
    expect(page).to have_content("Recruitment cycle updated")

    @upcoming_cycle.reload
    expect(@upcoming_cycle.application_start_date.day).to eq(27)
    expect(@upcoming_cycle.application_start_date.month).to eq(9)
    expect(@upcoming_cycle.application_end_date.day).to eq(5)
    expect(@upcoming_cycle.application_end_date.month).to eq(10)
    expect(@upcoming_cycle.available_in_publish_from.day).to eq(RecruitmentCycle.current.available_for_support_users_from.succ.day)
    expect(@upcoming_cycle.available_in_publish_from.month).to eq(RecruitmentCycle.current.available_for_support_users_from.succ.month)
    expect(page).to have_content(@upcoming_cycle.year)
    expect(page).to have_content(I18n.l(@upcoming_cycle.application_start_date, format: :long))
    expect(page).to have_content(I18n.l(@upcoming_cycle.application_end_date, format: :long))
  end
end
