# frozen_string_literal: true

require "rails_helper"

feature "Editing visa sponsorship deadlines" do
  before do
    FeatureFlag.activate(:visa_sponsorship_deadline)
    and_i_am_authenticated_as_a_lead_school_provider_user
  end

  scenario "adds a deadline to a course without one" do
    given_a_course_exists_that_sponsors_visas_but_without_a_deadline
    when_i_visit_the_basic_details_tab
    and_i_change_my_answer_to_require_visa_deadline("Yes")
    and_i_add_a_date
    then_i_see_the_date_on_the_basic_details_tab
  end

  scenario "removes a deadline to a course with one" do
    given_a_course_exists_that_sponsors_skilled_worker_visas_and_has_a_deadline
    when_i_visit_the_basic_details_tab
    and_i_change_my_answer_to_require_visa_deadline("No")
    then_i_do_not_see_the_date_on_the_basic_details_tab
  end

  scenario "changes course with deadline to one that does not sponsor visas at all" do
    given_a_course_exists_that_sponsors_skilled_worker_visas_and_has_a_deadline
    when_i_visit_the_basic_details_tab
    and_i_change_my_answer_to_not_sponsor_visas_anymore
    then_the_deadline_is_no_longer_saved_on_the_course
    and_i_see_that_i_do_not_sponsor_skilled_worker_visas_on_the_basis_details_tab
  end

  scenario "changing the funding type of a course with a visa deadline" do
    given_a_course_exists_that_sponsors_skilled_worker_visas_and_has_a_deadline
    when_i_visit_the_basic_details_tab
    and_i_change_the_funding_type_and_no_longer_sponsor_visas
    then_the_deadline_is_no_longer_saved_on_the_course
    and_i_see_that_i_do_not_sponsor_student_visas_on_the_basis_details_tab
  end

private

  def and_i_am_authenticated_as_a_lead_school_provider_user
    @user = create(:user, providers: [build(:provider, sites: [build(:site)])])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def given_a_course_exists_that_sponsors_visas_but_without_a_deadline
    given_a_course_exists(funding: "salary", can_sponsor_skilled_worker_visa: true, visa_sponsorship_application_deadline_at: nil, accrediting_provider:)
  end

  def given_a_course_exists_that_sponsors_skilled_worker_visas_and_has_a_deadline
    visa_sponsorship_application_deadline_at = (accrediting_provider.recruitment_cycle.application_end_date - 1.day).change(hour: 23, min: 59)
    given_a_course_exists(funding: "salary", can_sponsor_skilled_worker_visa: true, visa_sponsorship_application_deadline_at:, accrediting_provider:)
  end

  def when_i_visit_the_basic_details_tab
    click_on "Courses"
    click_on @course.name_and_code
    click_on "Basic details"
  end

  def and_i_change_my_answer_to_require_visa_deadline(yes_or_no)
    click_on "Change visa sponsorship required"
    choose yes_or_no
    click_on "Update visa sponsorship application deadline"
  end

  def and_i_add_a_date
    @valid_date = accrediting_provider.recruitment_cycle.application_end_date - 1.day
    fill_in "Year", with: @valid_date.year
    fill_in "Month", with: @valid_date.month
    fill_in "Day", with: @valid_date.day

    click_on "Update date"
  end

  def then_i_see_the_date_on_the_basic_details_tab
    within(".govuk-notification-banner__content") do
      expect(page).to have_text "Visa sponsorship deadline and date updated"
    end
    expect(page).to have_text "Is there a visa sponsorship deadline?Yes"
    expect(page).to have_text "Visa sponsorship deadline#{@valid_date.to_fs(:govuk_date)}"
  end

  def then_i_do_not_see_the_date_on_the_basic_details_tab
    within(".govuk-notification-banner__content") do
      expect(page).to have_text "Visa sponsorship deadline updated"
    end
    within(".govuk-summary-list") do
      expect(page).to have_text "Is there a visa sponsorship deadline?No"
      expect(page).to have_no_text "Visa sponsorship deadline"
    end
  end

  def and_i_change_the_funding_type_and_no_longer_sponsor_visas
    click_on "Change funding type"
    choose "Fee - no salary"
    click_on "Update funding type"

    choose "No"
    click_on "Update visa sponsorship"
  end

  def and_i_change_my_answer_to_not_sponsor_visas_anymore
    click_on "Change can sponsor skilled_worker visa"
    choose "No"
    click_on "Update visa sponsorship"
  end

  def then_the_deadline_is_no_longer_saved_on_the_course
    expect(@course.reload.visa_sponsorship_application_deadline_at).to be_nil
  end

  def and_i_see_that_i_do_not_sponsor_skilled_worker_visas_on_the_basis_details_tab
    expect(page).to have_no_text "Visa sponsorship deadline"
    expect(page).to have_no_text "Is there a visa sponsorship deadline?No"
    expect(page).to have_text "Skilled Worker visasNo - cannot sponsor"
  end

  def and_i_see_that_i_do_not_sponsor_student_visas_on_the_basis_details_tab
    expect(page).to have_no_text "Visa sponsorship deadline"
    expect(page).to have_no_text "Is there a visa sponsorship deadline?No"
    expect(page).to have_text "Student visasNo - cannot sponsor"
  end

  def accrediting_provider
    @current_user.providers.first
  end
end
