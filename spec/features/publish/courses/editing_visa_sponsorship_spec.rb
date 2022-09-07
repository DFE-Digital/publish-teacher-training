# frozen_string_literal: true

require "rails_helper"

feature "Editing visa sponsorship", { can_edit_current_and_next_cycles: false } do
  before do
    given_the_visa_sponsorship_on_course_feature_flag_is_active
    and_i_am_authenticated_as_a_lead_school_provider_user
  end

  context "fee paying course" do
    scenario "i can update the student visa" do
      given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
      when_i_visit_the_course_student_visa_sponsorship_edit_page
      and_i_choose_yes_to_the_student_sponsorship_question
      and_i_continue
      and_i_click_on_basic_details
      then_i_should_see_that_the_student_visa_can_be_sponsored
    end
  end

  context "salaried course" do
    scenario "i can update the skilled worker visa" do
      given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
      when_i_visit_the_course_skilled_worker_visa_sponsorship_edit_page
      and_i_choose_yes_to_the_skilled_worker_sponsorship_question
      and_i_continue
      and_i_click_on_basic_details
      then_i_should_see_that_the_skilled_worker_visa_can_be_sponsored
    end
  end

  def given_the_visa_sponsorship_on_course_feature_flag_is_active
    allow(Settings.features).to receive(:visa_sponsorship_on_course).and_return(true)
  end

  def and_i_am_authenticated_as_a_lead_school_provider_user
    @user = create(:user, providers: [build(:provider, sites: [build(:site)])])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
    given_a_course_exists(funding_type: "fee", can_sponsor_student_visa: false)
  end

  def given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
    given_a_course_exists(funding_type: "salary", can_sponsor_skilled_worker_visa: false)
  end

  def and_i_click_on_basic_details
    provider_courses_show_page.basic_details_link.click
  end

  def when_i_visit_the_course_student_visa_sponsorship_edit_page
    student_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_skilled_worker_visa_sponsorship_edit_page
    skilled_worker_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_choose_yes_to_the_student_sponsorship_question
    student_visa_sponsorship_edit_page.yes.choose
  end

  def and_i_choose_yes_to_the_skilled_worker_sponsorship_question
    skilled_worker_visa_sponsorship_edit_page.yes.choose
  end

  def and_i_continue
    click_button "Save"
  end

  def provider
    @current_user.providers.first
  end

  def then_i_should_see_that_the_student_visa_can_be_sponsored
    expect(page).to have_text "Student visaYes - can sponsor"
  end

  def then_i_should_see_that_the_skilled_worker_visa_can_be_sponsored
    expect(page).to have_text "Skilled worker visaYes - can sponsor"
  end
end
