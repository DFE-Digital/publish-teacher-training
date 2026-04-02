# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Viewing financial incentives for a subject" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: @user)
  end

  scenario "navigating to financial incentives tab from subject details" do
    given_i_visit_the_subject_details_page
    then_i_see_the_details_tab_is_active
    when_i_click_the_financial_incentives_tab
    then_i_see_the_financial_incentives_page
    and_i_see_the_financial_incentive_details
  end

  scenario "navigating back to details tab from financial incentives" do
    given_i_visit_the_financial_incentives_page
    when_i_click_the_details_tab
    then_i_see_the_subject_details_page
  end

  def given_a_support_user_exists
    @user = create(:user, :admin)
  end

  def given_i_visit_the_subject_details_page
    visit support_subject_path(mathematics)
  end

  def given_i_visit_the_financial_incentives_page
    visit financial_incentives_support_subject_path(mathematics)
  end

  def then_i_see_the_details_tab_is_active
    expect(page).to have_link("Details", class: "app-tab-navigation__link")
    expect(page).to have_link("Financial Incentives", class: "app-tab-navigation__link")
  end

  def when_i_click_the_financial_incentives_tab
    click_link_or_button "Financial Incentives"
  end

  def then_i_see_the_financial_incentives_page
    expect(page).to have_current_path(financial_incentives_support_subject_path(mathematics))
    expect(page).to have_content(mathematics.subject_name)
  end

  def and_i_see_the_financial_incentive_details
    within(".govuk-summary-list") do
      expect(page).to have_content("Bursary amount")
      expect(page).to have_content("Scholarship")
      expect(page).to have_content("Non uk bursary eligible")
      expect(page).to have_content("Non uk scholarship eligible")
    end
  end

  def when_i_click_the_details_tab
    click_link_or_button "Details"
  end

  def then_i_see_the_subject_details_page
    expect(page).to have_current_path(support_subject_path(mathematics))
    expect(page).to have_content("Subject code")
    expect(page).to have_content("Subject name")
  end

  def mathematics
    @mathematics ||= Subject.find_by(subject_name: "Mathematics")
  end
end
