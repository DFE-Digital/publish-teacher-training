# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Filtering subjects by financial incentives" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: @user)
    given_only_mathematics_and_physics_have_financial_incentives
  end

  scenario "filtering to show only subjects with financial incentives" do
    given_i_visit_the_support_subjects_page
    then_i_see_all_subjects
    when_i_check_the_financial_incentives_filter
    and_i_apply_the_filters
    then_the_filter_checkbox_is_still_checked
    and_i_see_only_mathematics_and_physics
  end

  scenario "combining text search with financial incentives filter" do
    given_i_visit_the_support_subjects_page
    when_i_search_for("Mathematics")
    and_i_check_the_financial_incentives_filter
    and_i_apply_the_filters
    then_i_see_only_mathematics
  end

  def given_a_support_user_exists
    @user = create(:user, :admin)
  end

  def given_only_mathematics_and_physics_have_financial_incentives
    FinancialIncentive.update_all(bursary_amount: nil, scholarship: nil)
    mathematics.financial_incentive.update!(bursary_amount: "10000")
    physics.financial_incentive.update!(scholarship: "30000")
  end

  def given_i_visit_the_support_subjects_page
    visit support_subjects_path
  end

  def then_i_see_all_subjects
    expect(subject_count).to eq(10)
    expect(page).to have_css(".govuk-pagination")
  end

  def when_i_check_the_financial_incentives_filter
    check "Has financial incentives"
  end

  alias_method :and_i_check_the_financial_incentives_filter, :when_i_check_the_financial_incentives_filter

  def and_i_apply_the_filters
    click_link_or_button "Apply filters"
  end

  def then_the_filter_checkbox_is_still_checked
    expect(page).to have_checked_field("Has financial incentives")
  end

  def and_i_see_only_mathematics_and_physics
    expect(subject_count).to eq(2)
    expect(page).to have_content("Mathematics")
    expect(page).to have_content("Physics")
    expect(page).not_to have_css(".govuk-pagination")
  end

  def when_i_search_for(term)
    fill_in "text_search", with: term
  end

  def then_i_see_only_mathematics
    expect(subject_count).to eq(1)
    expect(page).to have_content("Mathematics")
    expect(page).not_to have_content("Physics")
  end

  def subject_count
    page.all("table tbody tr").count
  end

  def mathematics
    @mathematics ||= Subject.find_by(subject_name: "Mathematics")
  end

  def physics
    @physics ||= Subject.find_by(subject_name: "Physics")
  end
end
