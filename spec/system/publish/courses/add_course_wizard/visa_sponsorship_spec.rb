# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard visa sponsorship step", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
  end

  scenario "choosing yes to visa sponsorship and continues to courses index" do
    given_i_am_authenticated_as_an_accredited_provider_user
    and_i_have_wizard_state_for_visa_sponsorship
    when_i_visit_the_wizard_visa_sponsorship_page
    and_i_choose_yes_to_the_visa_sponsorship_question
    and_i_click_continue
    then_i_am_taken_to_the_visa_sponsorship_application_deadline_required_page
  end

  scenario "choosing no to visa sponsorship and continues to start date page" do
    given_i_am_authenticated_as_an_accredited_provider_user
    and_i_have_wizard_state_for_visa_sponsorship
    when_i_visit_the_wizard_visa_sponsorship_page
    and_i_choose_no_to_the_visa_sponsorship_question
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "choosing nil to visa sponsorship and shows validation errors" do
    given_i_am_authenticated_as_an_accredited_provider_user
    and_i_have_wizard_state_for_visa_sponsorship
    when_i_visit_the_wizard_visa_sponsorship_page
    and_i_click_continue
    then_i_have_errors_on_the_visa_sponsorship_step
  end

  scenario "accredited provider that cannot sponsor student visas shows organisation question and overseas guidance" do
    given_i_am_authenticated_as_an_accredited_provider_user(can_sponsor_student_visa: false)
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_organisation_question
    and_i_see_recruiting_from_overseas_guidance
  end

  scenario "accredited provider that can sponsor student visas shows organisation question without overseas guidance" do
    given_i_am_authenticated_as_an_accredited_provider_user(can_sponsor_student_visa: true)
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_organisation_question
    and_i_do_not_see_recruiting_from_overseas_guidance
  end

  scenario "school-based provider shows availability question" do
    given_i_am_authenticated_as_a_school_based_provider_user
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_availability_question
    and_i_do_not_see_recruiting_from_overseas_guidance
    and_i_do_not_see_accrediting_provider_inset_text
  end

  scenario "school-based provider with accrediting partner that cannot sponsor shows inset text" do
    given_i_am_authenticated_as_a_school_based_provider_user_with_accredited_partner(can_sponsor_student_visa: false)
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_availability_question
    and_i_see_accrediting_partner_cannot_sponsor_inset_text
    and_i_see_no_selected_by_default
  end

  scenario "school-based provider with accrediting partner that cannot sponsor and continues without choosing" do
    given_i_am_authenticated_as_a_school_based_provider_user_with_accredited_partner(can_sponsor_student_visa: false)
    when_i_visit_the_wizard_visa_sponsorship_page
    and_i_click_continue
    then_i_am_taken_to_the_start_date_page
  end

  scenario "school-based provider with accrediting partner that can sponsor shows inset text" do
    given_i_am_authenticated_as_a_school_based_provider_user_with_accredited_partner(can_sponsor_student_visa: true)
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_availability_question
    and_i_see_accrediting_partner_can_sponsor_inset_text
  end

  scenario "school-based provider with multiple accrediting partners shows availability question only" do
    given_i_am_authenticated_as_a_school_based_provider_user_with_multiple_accredited_partners
    when_i_visit_the_wizard_visa_sponsorship_page
    then_i_see_the_common_visa_sponsorship_page_content
    and_i_see_the_availability_question
    and_i_do_not_see_accrediting_provider_inset_text
  end

private

  def given_i_am_authenticated_as_an_accredited_provider_user(can_sponsor_student_visa: false)
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          :accredited_provider,
          can_sponsor_student_visa:,
          sites: wizard_sites,
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_school_based_provider_user
    @user = create(
      :user,
      providers: [
        create(
          :provider,
          provider_type: :lead_school,
          can_sponsor_student_visa: false,
          sites: wizard_sites,
        ),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_school_based_provider_user_with_accredited_partner(can_sponsor_student_visa:)
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      can_sponsor_student_visa: false,
      sites: wizard_sites,
    )
    @accrediting_provider = create(
      :accredited_provider,
      can_sponsor_student_visa:,
      recruitment_cycle: school_provider.recruitment_cycle,
    )
    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: @accrediting_provider,
    )

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_school_based_provider_user_with_multiple_accredited_partners
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      can_sponsor_student_visa: false,
      sites: wizard_sites,
    )
    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: create(:accredited_provider, recruitment_cycle: school_provider.recruitment_cycle),
    )
    create(
      :provider_partnership,
      training_provider: school_provider,
      accredited_provider: create(:accredited_provider, recruitment_cycle: school_provider.recruitment_cycle),
    )

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_wizard_state_for_visa_sponsorship
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(level: "secondary")
  end

  def when_i_visit_the_wizard_visa_sponsorship_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :visa_sponsorship,
      state_key: wizard_state_key,
    )
  end

  def and_i_choose_yes_to_the_visa_sponsorship_question
    choose "Yes"
  end

  def and_i_choose_no_to_the_visa_sponsorship_question
    choose "No"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_am_taken_to_the_visa_sponsorship_application_deadline_required_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :visa_sponsorship_application_deadline_required,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_am_taken_to_the_start_date_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :start_date,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def then_i_have_errors_on_the_visa_sponsorship_step
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select if student visas can be sponsored for this course")
  end

  def then_i_see_the_common_visa_sponsorship_page_content
    expect(page).to have_content("Add course")
    expect(page).to have_content("Student visas")
    expect(page).to have_field("Yes", type: "radio")
    expect(page).to have_field("No", type: "radio")
    expect(page).to have_button("Continue")
  end

  def and_i_see_the_organisation_question
    expect(page).to have_content("Can your organisation sponsor Student visas for this course?")
    expect(page).not_to have_content("Is Student visa sponsorship available for this course?")
  end

  def and_i_see_the_availability_question
    expect(page).to have_content("Is Student visa sponsorship available for this course?")
    expect(page).not_to have_content("Can your organisation sponsor Student visas for this course?")
  end

  def and_i_see_recruiting_from_overseas_guidance
    expect(page).to have_content("Learn more about")
    expect(page).to have_link(
      "recruiting trainee teachers from overseas",
      href: "https://www.gov.uk/guidance/recruit-trainee-teachers-from-overseas-accredited-itt-providers",
    )
  end

  def and_i_do_not_see_recruiting_from_overseas_guidance
    expect(page).not_to have_content("Learn more about")
    expect(page).not_to have_link("recruiting trainee teachers from overseas")
  end

  def and_i_see_accrediting_partner_can_sponsor_inset_text
    expect(page).to have_content(
      "#{@accrediting_provider.provider_name} can sponsor Student visas for some of their courses.",
    )
  end

  def and_i_see_accrediting_partner_cannot_sponsor_inset_text
    expect(page).to have_content(
      "#{@accrediting_provider.provider_name} have said they cannot sponsor Student visas so we have defaulted your answer to 'No'.",
    )
    expect(page).to have_content(
      "If your organisation would like to sponsor Student visas, contact #{@accrediting_provider.provider_name}.",
    )
  end

  def and_i_do_not_see_accrediting_provider_inset_text
    expect(page).not_to have_css(".govuk-inset-text")
  end

  def and_i_see_no_selected_by_default
    expect(page).to have_checked_field("No")
    expect(page).to have_unchecked_field("Yes")
  end

  def wizard_sites
    [
      build(:site),
      build(:site),
      build(:site, :study_site),
      build(:site, :study_site),
    ]
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
