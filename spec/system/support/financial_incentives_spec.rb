# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Financial incentives support" do
  include DfESignInUserHelper
  include SettingsPageSpecsHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: support_user)
    and_the_current_year_has_no_financial_incentives
    and_the_next_year_has_no_financial_incentives
  end

  scenario "creating a new year from the landing page and repairing a missing incentive" do
    given_i_visit_the_support_settings_page
    when_i_click_financial_incentives
    then_i_see_the_financial_incentives_landing_page
    and_i_see_the_current_year_link
    and_i_see_the_create_button_for_the_next_year

    when_i_create_financial_incentives_for_the_next_year
    then_financial_incentives_are_created_for_all_active_subjects
    and_discontinued_subjects_do_not_get_financial_incentives
    and_i_am_on_the_next_year_page

    given_mathematics_is_missing_a_financial_incentive
    when_i_visit_the_next_year_financial_incentives_page
    then_i_see_mathematics_is_missing_a_financial_incentive

    when_i_create_a_blank_financial_incentive_for_mathematics
    then_mathematics_has_a_blank_hidden_financial_incentive
  end

  scenario "publishing a year and confirming edits to a visible incentive" do
    given_the_current_year_has_hidden_financial_incentives
    when_i_visit_the_current_year_financial_incentives_page
    and_i_choose_to_make_the_current_year_visible
    then_i_see_the_publish_confirmation_page

    when_i_confirm_the_year_should_be_visible
    then_the_current_year_is_visible
    and_physics_has_a_visible_financial_incentive

    when_i_edit_the_physics_financial_incentive
    and_i_change_the_bursary_amount
    then_i_see_the_visible_incentive_confirmation_page

    when_i_confirm_the_financial_incentive_changes
    then_the_physics_financial_incentive_is_updated
  end

  scenario "marking a subject's incentive as degree dependent" do
    given_the_current_year_has_visible_financial_incentives
    when_i_visit_the_current_year_financial_incentives_page
    when_i_edit_the_physics_financial_incentive
    and_i_mark_the_incentive_as_degree_dependent
    then_i_see_degree_dependent_on_the_confirmation_page("Yes")

    when_i_confirm_the_financial_incentive_changes
    then_physics_shows_degree_dependent_on_the_financial_incentives_page("Yes")

    when_i_edit_the_physics_financial_incentive
    and_i_unmark_the_incentive_as_degree_dependent
    then_i_see_degree_dependent_on_the_confirmation_page("No")

    when_i_confirm_the_financial_incentive_changes
    then_physics_shows_degree_dependent_on_the_financial_incentives_page("No")
  end

  scenario "showing the published tag for years with displayed incentives" do
    given_the_current_year_has_visible_financial_incentives
    when_i_visit_the_financial_incentives_landing_page
    then_i_see_the_current_year_link_with_a_published_tag
    and_i_do_not_see_the_incentives_table
  end

  scenario "visiting an unsupported year redirects to the landing page" do
    when_i_visit_the_financial_incentives_page_with_year(9999)
    then_i_see_the_financial_incentives_landing_page
  end

  scenario "I can navigate back to the settings page via the backlink", travel: mid_cycle do
    given_i_visit_the_support_settings_page
    when_i_click_financial_incentives
    then_i_see_the_backlink_to_the_settings_page
    then_i_click_back_button
    then_i_am_on_the_settings_page
  end

private

  attr_reader :support_user, :mathematics, :physics_incentive

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
  end

  def and_the_current_year_has_no_financial_incentives
    FinancialIncentive.for_year(current_year).delete_all
  end

  def and_the_next_year_has_no_financial_incentives
    FinancialIncentive.for_year(next_year).delete_all
  end

  def given_i_visit_the_support_settings_page
    visit support_settings_path
  end

  def when_i_click_financial_incentives
    click_on "Financial incentives"
  end

  def when_i_visit_the_financial_incentives_landing_page
    visit support_financial_incentives_path
  end

  def then_i_see_the_financial_incentives_landing_page
    expect(page).to have_current_path(support_financial_incentives_path)
    expect(page).to have_css("h1", text: "Financial incentives")
    expect(page).to have_css("h2", text: "Recruitment cycles")
    expect(page).to have_link("financial incentives feature flag", href: support_feature_flags_path)
    expect(page).to have_content("recruitment cycle marked as 'Published'")
    expect(page).to have_content("If the feature flag is deactivated")
  end

  def and_i_see_the_current_year_link
    expect(page).to have_link(current_year_label, href: year_support_financial_incentives_path(current_year))
  end

  def and_i_see_the_create_button_for_the_next_year
    expect(page).to have_button("Create financial incentives for #{next_year_range}")
  end

  def when_i_create_financial_incentives_for_the_next_year
    click_link_or_button "Create financial incentives for #{next_year_range}"
  end

  def then_financial_incentives_are_created_for_all_active_subjects
    within(".govuk-notification-banner--success") do
      expect(page).to have_css(
        ".govuk-notification-banner__heading",
        text: "Financial incentives created for the #{next_year_range} recruitment cycle",
      )
      expect(page).to have_css(
        "p.govuk-body",
        text: "The currently visible financial incentives have been copied to this cycle.",
      )
    end
    expect(page).to have_no_content("translation missing")
    expect(FinancialIncentive.for_year(next_year).where(subject: Subject.active).count).to eq(Subject.active.count)
  end

  def and_discontinued_subjects_do_not_get_financial_incentives
    expect(FinancialIncentive.for_year(next_year).where(subject_id: DiscontinuedSubject.select(:id))).to be_empty
  end

  def and_i_am_on_the_next_year_page
    expect(page).to have_current_path(year_support_financial_incentives_path(next_year))
  end

  def given_mathematics_is_missing_a_financial_incentive
    @mathematics = Subject.find_by!(subject_name: "Mathematics")
    FinancialIncentive.find_by!(subject: mathematics, year: next_year).destroy!
  end

  def when_i_visit_the_next_year_financial_incentives_page
    visit year_support_financial_incentives_path(next_year)
  end

  def when_i_visit_the_current_year_financial_incentives_page
    visit year_support_financial_incentives_path(current_year)
  end

  def when_i_visit_the_financial_incentives_page_with_year(year)
    visit year_support_financial_incentives_path(year)
  end

  def then_i_see_mathematics_is_missing_a_financial_incentive
    expect(page).to have_content("1 subject missing financial incentives for #{next_year}")

    within("tr", text: mathematics.subject_name) do
      expect(page).to have_content("Missing")
      expect(page).to have_button("Create blank incentive")
    end
  end

  def when_i_create_a_blank_financial_incentive_for_mathematics
    within("tr", text: mathematics.subject_name) do
      click_link_or_button "Create blank incentive"
    end
  end

  def then_mathematics_has_a_blank_hidden_financial_incentive
    expect(page).to have_content("Blank financial incentive for Mathematics created")
    expect(financial_incentive_for(mathematics, year: next_year)).not_to be_displayed
  end

  def given_the_current_year_has_hidden_financial_incentives
    FinancialIncentives::CreateYearService.call(year: current_year)
  end

  def and_i_choose_to_make_the_current_year_visible
    click_link_or_button "Make #{current_year} incentives visible"
  end

  def then_i_see_the_publish_confirmation_page
    expect(page).to have_content("Make #{current_year} financial incentives visible?")
    expect(page).to have_content("This will hide the currently visible incentives")
    expect(page).to have_no_content("translation missing")
  end

  def when_i_confirm_the_year_should_be_visible
    click_link_or_button "Make financial incentives visible"
  end

  def then_the_current_year_is_visible
    expect(page).to have_content("Financial incentives for #{current_year} are now visible")
  end

  def and_physics_has_a_visible_financial_incentive
    @physics_incentive = financial_incentive_for(physics, year: current_year)
    expect(physics_incentive).to be_displayed
  end

  def when_i_edit_the_physics_financial_incentive
    within("tr", text: physics.subject_name) do
      click_link_or_button "Change"
    end
  end

  def and_i_change_the_bursary_amount
    fill_in "Bursary amount", with: "12345"
    click_link_or_button "Update"
  end

  def then_i_see_the_visible_incentive_confirmation_page
    expect(page).to have_content("Confirm changes to this visible financial incentive")
    expect(page).to have_content("£12,345")
    expect(page).to have_no_content("translation missing")
  end

  def when_i_confirm_the_financial_incentive_changes
    click_link_or_button "Confirm changes"
  end

  def then_the_physics_financial_incentive_is_updated
    expect(page).to have_content("Financial incentive for Physics updated")
    expect(physics_incentive.reload.bursary_amount).to eq("12345")
  end

  def given_the_current_year_has_visible_financial_incentives
    given_the_current_year_has_hidden_financial_incentives
    FinancialIncentives::PublishYearService.call(year: current_year)
  end

  def then_i_see_the_current_year_link_with_a_published_tag
    within("li", text: current_year_label) do
      expect(page).to have_link(current_year_label, href: year_support_financial_incentives_path(current_year))
      expect(page).to have_content("Published")
    end
  end

  def and_i_do_not_see_the_incentives_table
    expect(page).to have_no_css("table")
    expect(page).to have_no_content("Bursary")
  end

  def and_i_mark_the_incentive_as_degree_dependent
    check "Incentive amount depends on the candidate's degree"
    click_link_or_button "Update"
  end

  def and_i_unmark_the_incentive_as_degree_dependent
    uncheck "Incentive amount depends on the candidate's degree"
    click_link_or_button "Update"
  end

  def then_i_see_degree_dependent_on_the_confirmation_page(value)
    within_summary_row("Degree dependent") do
      expect(page).to have_content(value)
    end
  end

  def then_physics_shows_degree_dependent_on_the_financial_incentives_page(value)
    expect(page).to have_content("Financial incentive for Physics updated")

    headings = page.all("thead th").map(&:text)
    physics_cells = page.find("tbody tr", text: physics.subject_name).all("td, th").map(&:text)
    expect(headings.zip(physics_cells).to_h).to include("Degree dependent" => value)
  end

  def current_year
    @current_year ||= FinancialIncentive.current_year
  end

  def next_year
    @next_year ||= Find::CycleTimetable.next_year
  end

  def next_year_range
    FinancialIncentive.year_range(next_year)
  end

  def current_year_label
    "#{FinancialIncentive.year_range(current_year)} - current"
  end

  def physics
    @physics ||= Subject.find_by!(subject_name: "Physics")
  end

  def financial_incentive_for(subject, year:)
    FinancialIncentive.find_by!(subject:, year:)
  end
end
