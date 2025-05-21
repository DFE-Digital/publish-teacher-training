# frozen_string_literal: true

require "rails_helper"

feature "Editing apprenticeship" do
  before do
    and_i_am_authenticated_as_accredited_provider_provider_user
  end

  context "apprenticeship to non apprenticeship course" do
    scenario "i am taken to the Student visa step" do
      given_there_is_apprenticeship_course
      when_i_visit_the_publish_courses_apprenticeship_edit_page
      when_i_select(:fee)
      and_i_continue
      then_i_should_be_on_the_student_visa_edit_page
      when_i_go_back
      then_i_should_be_on_the_publish_courses_apprenticeship_edit_page
      when_i_select(:fee)
      and_i_continue
      then_i_should_be_on_the_student_visa_edit_page
      when_i_update_the_student_visa_to_be_sponsored
      then_i_should_be_on_the_visa_deadline_required_page
      when_i_select_no_deadline
      then_i_see_the_no_deadline_success_message
    end
  end

  context "non apprenticeship to apprenticeship course" do
    scenario "i am taken to the skilled worker visa step" do
      given_there_is_fee_course
      when_i_visit_the_publish_courses_apprenticeship_edit_page
      when_i_select(:apprenticeship)
      and_i_continue
      then_i_should_be_on_the_publish_courses_skilled_worker_visa_sponsorship_edit_page
      when_i_go_back
      then_i_should_be_on_the_publish_courses_apprenticeship_edit_page
      when_i_select(:apprenticeship)
      and_i_continue
      then_i_should_be_on_the_publish_courses_skilled_worker_visa_sponsorship_edit_page
      when_i_update_the_skilled_worker_visa_to_be_sponsored
      then_i_should_be_on_the_visa_deadline_required_page
      when_i_select_no_deadline
      then_i_see_the_no_deadline_success_message
    end
  end

private

  def when_i_go_back
    click_link_or_button("Back")
  end

  def then_i_should_be_on_the_publish_courses_apprenticeship_edit_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Settings.current_recruitment_cycle_year}/courses/#{course.course_code}/funding-type")
  end

  def and_i_am_authenticated_as_accredited_provider_provider_user
    given_i_am_authenticated(user: create(:user, providers: [create(:provider, :accredited_provider)]))
  end

  def given_there_is_fee_course
    given_a_course_exists(
      funding: "fee",
    )
  end

  def given_there_is_funding_fee_course
    given_a_course_exists(
      funding_type: "fee",
    )
  end

  def given_there_is_apprenticeship_course
    given_a_course_exists(
      funding: "apprenticeship",
    )
  end

  def when_i_visit_the_publish_courses_apprenticeship_edit_page
    publish_courses_funding_type_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def when_i_visit_the_course_publish_courses_skilled_worker_visa_sponsorship_edit_page
    publish_courses_skilled_worker_visa_sponsorship_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_continue
    publish_courses_apprenticeship_edit_page.update.click
  end

  def provider
    @current_user.providers.first
  end

  def when_i_select(option)
    publish_courses_funding_type_edit_page.funding_type_fields.send(option).click
  end

  def then_i_should_be_on_the_publish_courses_skilled_worker_visa_sponsorship_edit_page
    expect(publish_courses_skilled_worker_visa_sponsorship_edit_page).to be_displayed
  end

  def then_i_should_be_on_the_student_visa_edit_page
    expect(publish_courses_student_visa_sponsorship_edit_page).to be_displayed
  end

  def when_i_update_the_skilled_worker_visa_to_be_sponsored
    publish_courses_skilled_worker_visa_sponsorship_edit_page.yes.choose
    publish_courses_skilled_worker_visa_sponsorship_edit_page.update.click
  end

  def when_i_update_the_student_visa_to_be_sponsored
    publish_courses_student_visa_sponsorship_edit_page.yes.choose
    publish_courses_student_visa_sponsorship_edit_page.update.click
  end

  def then_i_should_be_on_the_visa_deadline_required_page
    expect(page).to have_content "Is there a deadline for applications that require visa sponsorship?"
  end

  def when_i_select_no_deadline
    choose "No"
    click_on "Update"
  end

  def then_i_see_the_no_deadline_success_message
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Teaching apprenticeship and visa sponsorship and deadline updated"
    end
  end

  def then_i_should_see_a_success_message_for(visa_type)
    expect(page).to have_content(I18n.t("visa_sponsorships.updated.apprenticeship_and_visa", visa_type:))
  end

  def accrediting_provider
    @current_user.providers.first
  end
end
