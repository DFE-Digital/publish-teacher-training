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
      when_i_select_an_fee_or_salary(:salary)
      and_i_continue
      then_i_should_be_on_the_skilled_worker_visa_sponsorship_edit_page
      when_i_update_the_skilled_worker_visa_to_be_sponsored
      then_i_should_see_a_success_message_for("Skilled Worker")
    end
  end

  context "salaried to fee paying course" do
    scenario "i am taken to the student visa step" do
      given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
      when_i_visit_the_funding_type_edit_page
      when_i_select_an_fee_or_salary(:fee)
      and_i_continue
      then_i_should_be_on_the_student_visa_edit_page
      when_i_update_the_student_visa_to_be_sponsored
      then_i_should_see_a_success_message_for("Student")
    end
  end

  def given_the_visa_sponsorship_on_course_feature_flag_is_active
    allow(Settings.features).to receive(:visa_sponsorship_on_course).and_return(true)
  end

  def and_i_am_authenticated_as_a_lead_school_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_body)]))
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

  def provider
    @current_user.providers.first
  end

  def when_i_select_an_fee_or_salary(funding_type)
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
    expect(page).to have_content(I18n.t("visa_sponsorships.funding_and_visa_updated", visa_type:))
  end

  def accrediting_provider
    @current_user.providers.first
  end
end
