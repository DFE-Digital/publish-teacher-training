# frozen_string_literal: true

require "rails_helper"

feature "visa sponsorship (add course summary page)" do
  context "for lead school" do
    before do
      given_i_am_authenticated_as_a_provider_user
      when_i_visit_the_publish_course_confirmation_page
    end

    scenario "changing funding_type to fee shows the student question" do
      when_i_change_funding_type
      and_i_choose_fee
      and_i_click_continue
      then_i_should_see_the_student_visas_title

      when_i_choose_yes_for_student_visa
      and_i_select_no_student_visa
      and_i_click_continue
      then_i_should_be_back_on_the_publish_course_confirmation_page
    end

    scenario "changing funding_type to salaried shows the skilled worker question" do
      when_i_change_funding_type
      and_i_choose_salary
      and_i_click_continue
      then_i_should_see_the_skilled_worker_visas_title

      when_i_choose_yes_for_skilled_worker_visa
      and_i_select_no_skillled_worker_visa
      and_i_click_continue
      then_i_should_be_back_on_the_publish_course_confirmation_page
    end
  end

private

  def lead_school_provider
    build(:provider, sites: [build(:site)], study_sites: [build(:site, :study_site)])
  end

  def scitt_or_uni_provider
    build(:provider, :accredited_provider, sites: [build(:site)], study_sites: [build(:site, :study_site)])
  end

  def given_i_am_authenticated_as_a_provider_user(provider = lead_school_provider)
    @user = create(:user, providers: [provider])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def when_i_visit_the_publish_course_confirmation_page
    publish_course_confirmation_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      query: confirmation_params(provider),
    )
  end

  def when_i_change_apprenticeship
    publish_course_confirmation_page.details.apprenticeship.change_link.click
  end

  def and_i_choose_yes_for_apprenticeship
    publish_courses_new_apprenticeship_page.yes.click
  end

  def and_i_choose_no_for_apprenticeship
    publish_courses_new_apprenticeship_page.no.click
  end

  def when_i_change_funding_type
    publish_course_confirmation_page.details.funding_type.change_link.click
  end

  def and_i_choose_fee
    publish_courses_new_funding_type_page.funding_type_fields.fee.click
  end

  def and_i_choose_salary
    publish_courses_new_funding_type_page.funding_type_fields.salary.click
  end

  def and_i_click_continue
    click_link_or_button "Continue"
  end

  def then_i_should_see_the_student_visas_title
    expect(publish_courses_new_student_visa_sponsorship_page.title).to have_text("Student visas")
  end

  def then_i_should_see_the_skilled_worker_visas_title
    expect(publish_courses_new_skilled_worker_visa_sponsorship_page.title).to have_text("Skilled Worker visas")
  end

  def when_i_choose_yes_for_student_visa
    publish_courses_new_student_visa_sponsorship_page.yes.click
  end

  def when_i_choose_yes_for_skilled_worker_visa
    publish_courses_new_skilled_worker_visa_sponsorship_page.yes.click
  end

  def then_i_should_be_back_on_the_publish_course_confirmation_page
    expect(page).to have_text("Check your answers")
  end

  def and_i_select_no_student_visa
    choose "course_can_sponsor_student_visa_false"
  end

  def and_i_select_no_skillled_worker_visa
    choose "course_can_sponsor_skilled_worker_visa_false"
  end
end
