# frozen_string_literal: true

require "rails_helper"

# Existing data has pairs of kept school sites sharing a URN, which fails the
# site's own uniqueness validation. Picking one of them must not stop the
# course being added.
RSpec.describe "Add course wizard with a school whose URN is duplicated", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_the_provider_has_two_schools_sharing_a_urn
  end

  scenario "adding a course on one of the duplicated schools" do
    given_i_have_completed_the_wizard_choosing_the_duplicated_school
    when_i_visit_check_answers_page
    and_i_click_add_course
    then_i_see_no_sites_error
    and_the_course_is_created_on_the_duplicated_school
  end

  def given_i_am_authenticated_as_a_provider_user
    recruitment_cycle = find_or_create(:recruitment_cycle, year: Find::CycleTimetable.current_year)
    @user = create(:user, providers: [create(:provider, :accredited_provider, recruitment_cycle:)])

    given_i_am_authenticated(user: @user)
  end

  def and_the_provider_has_two_schools_sharing_a_urn
    @original_site = create(:site, :with_provider_school, provider:, location_name: "Main site")
    @duplicated_site = create(:site, :with_provider_school, provider:, location_name: "Wolfson Hillel Primary School")
    @duplicated_site.update_columns(urn: @original_site.urn)
  end

  def given_i_have_completed_the_wizard_choosing_the_duplicated_school
    primary_subject = find_or_create(:primary_subject, :primary)
    study_site = create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    CourseWizard::StateStores::CourseWizardStore.new(repository:).write(
      level: "primary",
      is_send: "false",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "undergraduate_degree_with_qts",
      school_uuids: [@duplicated_site.uuid],
      study_sites_ids: [study_site.id.to_s],
      start_date: "#{Date::MONTHNAMES[Date.current.month]} #{Find::CycleTimetable.current_year}",
      can_sponsor_student_visa: false,
      visa_sponsorship_application_deadline_required: false,
    )
  end

  def when_i_visit_check_answers_page
    visit publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step: :check_answers,
      state_key: wizard_state_key,
    )
  end

  def and_i_click_add_course
    click_on "Add course"
  end

  def then_i_see_no_sites_error
    expect(page).to have_no_content("Sites is invalid")
  end

  def and_the_course_is_created_on_the_duplicated_school
    expect(provider.courses.count).to eq(1)
    expect(provider.courses.order(:created_at).last.sites).to eq([@duplicated_site])
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
