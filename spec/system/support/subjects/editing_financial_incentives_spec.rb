# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Support subjects financial incentives" do
  include DfESignInUserHelper

  before do
    given_a_support_user_exists
    sign_in_system_test(user: @user)
  end

  scenario "updating an existing financial incentive" do
    given_mathematics_has_financial_incentive
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    when_i_click_on_the_mathematics_subject
    when_i_click_change_financial_incentive
    and_i_enter_financial_incentive_values(
      bursary_amount: "26000",
      scholarship: "28000",
      non_uk_bursary_eligible: true,
      non_uk_scholarship_eligible: true,
      subject_knowledge_enhancement_course_available: true,
    )
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_the_success_message
    and_i_see_updated_financial_incentive_details
  end

  scenario "creating a financial incentive when one does not exist" do
    given_mathematics_has_no_financial_incentive
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    when_i_click_on_the_mathematics_subject
    when_i_click_change_financial_incentive
    and_i_enter_financial_incentive_values(
      bursary_amount: "15000",
      scholarship: "",
      non_uk_bursary_eligible: true,
      non_uk_scholarship_eligible: false,
      subject_knowledge_enhancement_course_available: false,
    )
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_the_success_message
    and_i_see_created_financial_incentive_details
  end

  scenario "not creating a financial incentive when one does not exist and no details are entered" do
    given_mathematics_has_no_financial_incentive
    given_i_visit_the_support_subjects_page
    when_i_search_for_mathematics
    when_i_click_on_the_mathematics_subject
    when_i_click_change_financial_incentive
    and_i_click_update_subject
    then_i_am_redirected_to_the_subject_page
    and_i_see_the_success_message
    and_i_see_no_financial_incentive_was_created
  end

  def given_a_support_user_exists
    @user = create(:user, :admin)
  end

  def given_mathematics_has_financial_incentive
    mathematics.financial_incentive&.destroy!
    create(
      :financial_incentive,
      subject: mathematics,
      bursary_amount: "1000",
      scholarship: "2000",
      early_career_payments: "3000",
      non_uk_bursary_eligible: false,
      non_uk_scholarship_eligible: false,
      subject_knowledge_enhancement_course_available: false,
    )
  end

  def given_mathematics_has_no_financial_incentive
    mathematics.financial_incentive&.destroy!
  end

  def given_i_visit_the_support_subjects_page
    visit support_subjects_path
  end

  def when_i_search_for_mathematics
    fill_in "text_search", with: "Mathematics"
    click_link_or_button "Apply filters"
  end

  def when_i_click_on_the_mathematics_subject
    click_link_or_button "Mathematics"
  end

  def when_i_click_change_financial_incentive
    within(".govuk-summary-list__row", text: "Bursary amount") do
      click_link_or_button "Change"
    end
  end

  def and_i_enter_financial_incentive_values(
    bursary_amount:,
    scholarship:,
    non_uk_bursary_eligible:,
    non_uk_scholarship_eligible:,
    subject_knowledge_enhancement_course_available:
  )
    fill_in "subject[financial_incentive][bursary_amount]", with: bursary_amount
    fill_in "subject[financial_incentive][scholarship]", with: scholarship

    set_checkbox("Eligible for non-UK bursary", non_uk_bursary_eligible)
    set_checkbox("Eligible for non-UK scholarship", non_uk_scholarship_eligible)
    set_checkbox("Subject knowledge enhancement course available", subject_knowledge_enhancement_course_available)
  end

  def and_i_click_update_subject
    click_link_or_button "Update subject"
  end

  def then_i_am_redirected_to_the_subject_page
    expect(page).to have_current_path(support_subject_path(mathematics), ignore_query: true)
  end

  def and_i_see_the_success_message
    expect(page).to have_content("Subject successfully updated")
  end

  def and_i_see_updated_financial_incentive_details
    within(".govuk-summary-list") do
      expect(page).to have_content("26000")
      expect(page).to have_content("28000")
      expect(page).to have_content("Non-UK bursary eligible")
      expect(page).to have_content("Non-UK scholarship eligible")
      expect(page).to have_content("Subject knowledge enhancement course available")
    end

    financial_incentive = mathematics.reload.financial_incentive

    expect(financial_incentive.bursary_amount).to eq("26000")
    expect(financial_incentive.scholarship).to eq("28000")
    expect(financial_incentive.early_career_payments).to eq("3000")
    expect(financial_incentive.non_uk_bursary_eligible).to be(true)
    expect(financial_incentive.non_uk_scholarship_eligible).to be(true)
    expect(financial_incentive.subject_knowledge_enhancement_course_available).to be(true)
  end

  def and_i_see_created_financial_incentive_details
    within(".govuk-summary-list") do
      expect(page).to have_content("15000")
      expect(page).to have_content("Not available")
      expect(page).to have_content("Non-UK bursary eligible")
    end

    financial_incentive = mathematics.reload.financial_incentive

    expect(financial_incentive).to be_present
    expect(financial_incentive.bursary_amount).to eq("15000")
    expect(financial_incentive.scholarship).to be_nil
    expect(financial_incentive.early_career_payments).to be_nil
    expect(financial_incentive.non_uk_bursary_eligible).to be(true)
    expect(financial_incentive.non_uk_scholarship_eligible).to be(false)
    expect(financial_incentive.subject_knowledge_enhancement_course_available).to be(false)
  end

  def and_i_see_no_financial_incentive_was_created
    within(".govuk-summary-list") do
      expect(page).to have_content("Not available")
    end

    expect(mathematics.reload.financial_incentive).to be_nil
  end

  def set_checkbox(label, checked)
    checked ? check(label, allow_label_click: true) : uncheck(label, allow_label_click: true)
  end

  def mathematics
    @mathematics ||= Subject.find_by(subject_name: "Mathematics")
  end
end
