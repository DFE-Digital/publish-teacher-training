# frozen_string_literal: true

require "rails_helper"

feature "Editing funding type", { can_edit_current_and_next_cycles: false } do
  before do
    given_the_visa_sponsorship_on_course_feature_flag_is_active
    and_i_am_authenticated_as_a_lead_school_provider_user
  end

  context "fee paying to salaried course" do
    scenario "i am taken to the skilled worker visa step" do
      given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
      when_i_visit_the_funding_type_edit_page
      when_i_select_a_funding_type(:salary)
      and_i_continue
      then_i_should_be_on_the_skilled_worker_visa_sponsorship_edit_page
      when_i_update_the_skilled_worker_visa_to_be_sponsored
      then_i_should_see_a_success_message_for("Skilled Worker")
      and_the_course_should_have_updated_to_salaried_and_sponsor_skilled_worker_visa

      when_i_update_funding_type_back_to_fee_paying_and_student_visa_to_sponsored
      then_the_previously_updated_skilled_worker_visa_should_be_false
    end

    scenario "i cancel after changing funding type and changes are not retained" do
      given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
      when_i_visit_the_funding_type_edit_page
      when_i_select_a_funding_type(:salary)
      and_i_continue
      and_i_cancel
      then_the_course_should_should_still_be_fee_paying
    end
  end

  context "salaried to fee paying course" do
    scenario "i am taken to the student visa step" do
      given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
      when_i_visit_the_funding_type_edit_page
      when_i_select_a_funding_type(:fee)
      and_i_continue
      then_i_should_be_on_the_student_visa_edit_page
      when_i_update_the_student_visa_to_be_sponsored
      then_i_should_see_a_success_message_for("Student")
      and_the_course_should_have_updated_to_fee_and_sponsor_student_visa

      when_i_update_funding_type_back_to_salaried_and_skilled_worker_to_sponsored
      then_the_previously_updated_student_visa_should_be_false
    end

    scenario "i cancel after changing funding type and changes are not retained" do
      given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
      when_i_visit_the_funding_type_edit_page
      when_i_select_a_funding_type(:fee)
      and_i_continue
      and_i_cancel
      then_the_course_should_should_still_be_salaried
    end
  end

  def given_the_visa_sponsorship_on_course_feature_flag_is_active
    allow(Settings.features).to receive(:visa_sponsorship_on_course).and_return(true)
  end

  def and_i_am_authenticated_as_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider)]))
  end

  def given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
    given_a_course_exists(
      funding_type: "fee",
      can_sponsor_student_visa: false,
      accrediting_provider:,
    )
  end

  def given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
    given_a_course_exists(
      funding_type: "salary",
      can_sponsor_skilled_worker_visa: false,
      accrediting_provider:,
    )
  end

  def when_i_visit_the_funding_type_edit_page
    funding_type_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_skilled_worker_visa_sponsorship_edit_page
    skilled_worker_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_continue
    funding_type_edit_page.update.click
  end

  def and_i_cancel
    click_link "Cancel"
  end

  def then_the_course_should_should_still_be_fee_paying
    course.reload
    expect(course.funding_type).to eq("fee")
  end

  def then_the_previously_updated_skilled_worker_visa_should_be_false
    course.reload
    expect(course.can_sponsor_skilled_worker_visa).to be(false)
  end

  def then_the_previously_updated_student_visa_should_be_false
    course.reload
    expect(course.can_sponsor_student_visa).to be(false)
  end

  def then_the_course_should_should_still_be_salaried
    course.reload
    expect(course.funding_type).to eq("salary")
  end

  def when_i_update_funding_type_back_to_salaried_and_skilled_worker_to_sponsored
    when_i_visit_the_funding_type_edit_page
    when_i_select_a_funding_type(:salary)
    and_i_continue
    when_i_update_the_skilled_worker_visa_to_be_sponsored
  end

  def when_i_update_funding_type_back_to_fee_paying_and_student_visa_to_sponsored
    when_i_visit_the_funding_type_edit_page
    when_i_select_a_funding_type(:fee)
    and_i_continue
    when_i_update_the_student_visa_to_be_sponsored
  end

  def and_the_course_should_have_updated_to_salaried_and_sponsor_skilled_worker_visa
    course.reload
    expect(course.funding_type).to eq("salary")
    expect(course.can_sponsor_skilled_worker_visa).to be(true)
    expect(course.can_sponsor_student_visa).to be(false)
  end

  def and_the_course_should_have_updated_to_fee_and_sponsor_student_visa
    course.reload
    expect(course.funding_type).to eq("fee")
    expect(course.can_sponsor_skilled_worker_visa).to be(false)
    expect(course.can_sponsor_student_visa).to be(true)
  end

  def provider
    @current_user.providers.first
  end

  def when_i_select_a_funding_type(funding_type)
    funding_type_edit_page.funding_type_fields.send(funding_type).click
  end

  def then_i_should_be_on_the_skilled_worker_visa_sponsorship_edit_page
    expect(skilled_worker_visa_sponsorship_edit_page).to be_displayed
  end

  def then_i_should_be_on_the_student_visa_edit_page
    expect(student_visa_sponsorship_edit_page).to be_displayed
  end

  def when_i_update_the_skilled_worker_visa_to_be_sponsored
    skilled_worker_visa_sponsorship_edit_page.yes.choose
    skilled_worker_visa_sponsorship_edit_page.update.click
  end

  def when_i_update_the_student_visa_to_be_sponsored
    student_visa_sponsorship_edit_page.yes.choose
    student_visa_sponsorship_edit_page.update.click
  end

  def then_i_should_see_a_success_message_for(visa_type)
    expect(page).to have_content(I18n.t("visa_sponsorships.updated.funding_type_and_visa", visa_type:))
  end

  def accrediting_provider
    @current_user.providers.first
  end
end
