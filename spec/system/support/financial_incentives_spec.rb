# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Financial incentives support" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: support_user)
    and_the_current_year_has_no_financial_incentives
  end

  scenario "creating a new year and repairing a missing incentive" do
    given_i_visit_the_support_subjects_page
    when_i_click_financial_incentives
    then_i_see_the_financial_incentives_page
    and_i_see_there_are_no_incentives_for_the_current_year

    when_i_create_financial_incentives_for_the_current_year
    then_financial_incentives_are_created_for_all_active_subjects
    and_discontinued_subjects_do_not_get_financial_incentives

    given_mathematics_is_missing_a_financial_incentive
    when_i_visit_the_financial_incentives_page
    then_i_see_mathematics_is_missing_a_financial_incentive

    when_i_create_a_blank_financial_incentive_for_mathematics
    then_mathematics_has_a_blank_hidden_financial_incentive
  end

  scenario "publishing a year and confirming edits to a visible incentive" do
    given_the_current_year_has_hidden_financial_incentives
    when_i_visit_the_financial_incentives_page
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

private

  attr_reader :support_user, :mathematics, :physics_incentive

  def given_a_support_user_exists
    @support_user = create(:user, :admin)
  end

  def and_the_current_year_has_no_financial_incentives
    FinancialIncentive.for_year(current_year).delete_all
  end

  def given_i_visit_the_support_subjects_page
    visit support_subjects_path
  end

  def when_i_click_financial_incentives
    click_link_or_button "Financial Incentives"
  end

  def then_i_see_the_financial_incentives_page
    expect(page).to have_current_path(support_financial_incentives_path, ignore_query: true)
    expect(page).to have_content("Financial incentives")
  end

  def and_i_see_there_are_no_incentives_for_the_current_year
    expect(page).to have_content("There are no financial incentives for #{current_year}")
  end

  def when_i_create_financial_incentives_for_the_current_year
    click_link_or_button "Create financial incentives for #{current_year}"
  end

  def then_financial_incentives_are_created_for_all_active_subjects
    expect(page).to have_content("financial incentives for #{current_year} created")
    expect(FinancialIncentive.for_year(current_year).where(subject: Subject.active).count).to eq(Subject.active.count)
  end

  def and_discontinued_subjects_do_not_get_financial_incentives
    expect(FinancialIncentive.for_year(current_year).where(subject_id: DiscontinuedSubject.select(:id))).to be_empty
  end

  def given_mathematics_is_missing_a_financial_incentive
    @mathematics = Subject.find_by!(subject_name: "Mathematics")
    FinancialIncentive.find_by!(subject: mathematics, year: current_year).destroy!
  end

  def when_i_visit_the_financial_incentives_page
    visit support_financial_incentives_path(year: current_year)
  end

  def then_i_see_mathematics_is_missing_a_financial_incentive
    expect(page).to have_content("1 subject missing financial incentives for #{current_year}")

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
    expect(financial_incentive_for(mathematics)).not_to be_displayed
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
  end

  def when_i_confirm_the_year_should_be_visible
    click_link_or_button "Make financial incentives visible"
  end

  def then_the_current_year_is_visible
    expect(page).to have_content("Financial incentives for #{current_year} are now visible")
  end

  def and_physics_has_a_visible_financial_incentive
    @physics_incentive = financial_incentive_for(physics)
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
  end

  def when_i_confirm_the_financial_incentive_changes
    click_link_or_button "Confirm changes"
  end

  def then_the_physics_financial_incentive_is_updated
    expect(page).to have_content("Financial incentive for Physics updated")
    expect(physics_incentive.reload.bursary_amount).to eq("12345")
  end

  def current_year
    @current_year ||= FinancialIncentive.current_year
  end

  def physics
    @physics ||= Subject.find_by!(subject_name: "Physics")
  end

  def financial_incentive_for(subject)
    FinancialIncentive.find_by!(subject:, year: current_year)
  end
end
