require "rails_helper"

feature "visa sponsorship for lead school (add course summary page)", { can_edit_current_and_next_cycles: false } do
  before do
    given_the_visa_sponsorship_on_course_feature_flag_is_active
    given_i_am_authenticated_as_a_provider_user
    when_i_visit_the_course_confirmation_page
  end

  scenario "changing funding_type to fee shows the student question" do
    when_i_change_fee_or_salary
    and_i_choose_fee
    and_i_click_continue
    then_i_should_see_the_student_visas_title

    when_i_choose_yes_for_student_visa
    and_i_click_continue
    then_i_should_be_back_on_the_course_confirmation_page
  end

  scenario "changing funding_type to salaried shows the skilled worker question" do
    when_i_change_fee_or_salary
    and_i_choose_salary
    and_i_click_continue
    then_i_should_see_the_skilled_worker_visas_title

    when_i_choose_yes_for_skilled_worker_visa
    and_i_click_continue
    then_i_should_be_back_on_the_course_confirmation_page
  end

private

  def given_the_visa_sponsorship_on_course_feature_flag_is_active
    allow(Settings.features).to receive(:visa_sponsorship_on_course).and_return(true)
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, sites: [build(:site)])])
    @user.providers.first.courses << create(:course, :with_accrediting_provider)
    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def when_i_visit_the_course_confirmation_page
    course_confirmation_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: Settings.current_recruitment_cycle_year,
      query: confirmation_params(provider),
    )
  end

  def when_i_change_fee_or_salary
    course_confirmation_page.details.fee_or_salary.change_link.click
  end

  def and_i_choose_fee
    new_fee_or_salary_page.funding_type_fields.fee.click
  end

  def and_i_choose_salary
    new_fee_or_salary_page.funding_type_fields.salary.click
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def then_i_should_see_the_student_visas_title
    expect(new_student_visa_sponsorship_page.title).to have_text("Student visas")
  end

  def then_i_should_see_the_skilled_worker_visas_title
    expect(new_skilled_worker_visa_sponsorship_page.title).to have_text("Skilled worker visas")
  end

  def when_i_choose_yes_for_student_visa
    new_student_visa_sponsorship_page.yes.click
  end

  def when_i_choose_yes_for_skilled_worker_visa
    new_skilled_worker_visa_sponsorship_page.yes.click
  end

  def then_i_should_be_back_on_the_course_confirmation_page
    expect(page).to have_text("Check your answers before confirming")
  end
end
