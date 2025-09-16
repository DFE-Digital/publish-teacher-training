# frozen_string_literal: true

require "rails_helper"

feature "Editing visa sponsorship" do
  before do
    and_i_am_authenticated_as_a_lead_school_provider_user
  end

  context "fee paying course" do
    scenario "i can update the student visa" do
      given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
      when_i_visit_the_course_publish_courses_student_visa_sponsorship_edit_page
      and_i_choose_yes_to_the_student_sponsorship_question
      and_i_continue
      then_i_see_the_visa_sponsorship_deadline_required_page

      when_i_continue_with_no_deadline
      and_i_click_on_basic_details
      then_i_see_that_the_student_visa_can_be_sponsored
      and_i_see_there_is_no_deadline_required
    end
  end

  context "salaried course" do
    scenario "i can update the skilled worker visa" do
      given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
      and_i_am_in_mid_cycle
      when_i_visit_the_course_publish_courses_skilled_worker_visa_sponsorship_edit_page
      and_i_choose_yes_to_the_skilled_worker_sponsorship_question
      and_i_continue
      then_i_see_the_visa_sponsorship_deadline_required_page

      when_i_continue_with_yes_deadline
      then_i_see_the_visa_sponsorship_deadline_date_page

      when_i_add_a_date_and_continue
      and_i_click_on_basic_details
      then_i_should_see_that_the_skilled_worker_visa_can_be_sponsored
      and_i_see_the_visa_sponsorship_deadline_date
    end
  end

  def and_i_am_authenticated_as_a_lead_school_provider_user
    @user = create(:user, providers: [build(:provider, sites: [build(:site)])])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_i_am_in_mid_cycle
    Timecop.travel(Find::CycleTimetable.mid_cycle)
  end

  def given_there_is_a_fee_paying_course_i_want_to_edit_which_cant_sponsor_a_student_visa
    given_a_course_exists(funding: "fee", can_sponsor_student_visa: false, accrediting_provider:)
  end

  def given_there_is_a_salaried_course_i_want_to_edit_which_cant_sponsor_a_skilled_worker_visa
    given_a_course_exists(funding: "salary", can_sponsor_skilled_worker_visa: false, accrediting_provider:)
  end

  def and_i_click_on_basic_details
    click_on "Basic details"
  end

  def when_i_continue_with_no_deadline
    choose "No"
    click_on "Update"
  end

  def when_i_continue_with_yes_deadline
    choose "Yes"
    click_on "Update"
  end

  def when_i_visit_the_course_publish_courses_student_visa_sponsorship_edit_page
    publish_courses_student_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_publish_courses_skilled_worker_visa_sponsorship_edit_page
    publish_courses_skilled_worker_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_choose_yes_to_the_student_sponsorship_question
    publish_courses_student_visa_sponsorship_edit_page.yes.choose
  end

  def and_i_choose_yes_to_the_skilled_worker_sponsorship_question
    publish_courses_skilled_worker_visa_sponsorship_edit_page.yes.choose
  end

  def and_i_continue
    click_link_or_button "Update visa sponsorship"
  end

  def provider
    @current_user.providers.first
  end

  def then_i_see_that_the_student_visa_can_be_sponsored
    expect(page).to have_text "Student visasYes - can sponsor"
  end

  def and_i_see_there_is_no_deadline_required
    expect(page).to have_text "Is there a visa sponsorship deadline?No"
  end

  def and_i_see_the_visa_sponsorship_deadline_date
    expect(page).to have_text "Is there a visa sponsorship deadline?Yes"
    expect(page).to have_text "Visa sponsorship deadline#{@valid_date.to_fs(:govuk_date)}"
  end

  def then_i_see_the_visa_sponsorship_deadline_required_page
    expect(page).to have_content "Is there a deadline for applications that require visa sponsorship?"
  end

  def then_i_should_see_that_the_skilled_worker_visa_can_be_sponsored
    expect(page).to have_text "Skilled Worker visasYes - can sponsor"
  end

  def then_i_see_the_visa_sponsorship_deadline_date_page
    expect(page).to have_text("Date that applications close for visa sponsored candidates")
  end

  def when_i_add_a_date_and_continue
    @valid_date = Find::CycleTimetable.date(
      :apply_deadline,
      accrediting_provider.recruitment_cycle.year.to_i,
    ) - 1.day
    fill_in "Year", with: @valid_date.year
    fill_in "Month", with: @valid_date.month
    fill_in "Day", with: @valid_date.day

    click_on "Update date"
  end

  def accrediting_provider
    @current_user.providers.first
  end
end
