# frozen_string_literal: true

require "rails_helper"

# A change from check answers asks only the questions it affects: a question
# the change brings onto the path, then back to check answers. Back retraces
# the questions it asked.
RSpec.describe "Add course wizard changes that need further answers", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "changing fee to salary asks the skilled worker visa and deadline questions" do
    given_i_have_completed_a_fee_course(can_sponsor_student_visa: true, deadline_required: true)
    when_i_change(:funding_type)
    choose "Salary"
    and_i_click_continue

    then_i_am_on_step(:skilled_worker_visa, change_from: :funding_type)
    choose "Yes"
    and_i_click_continue

    then_i_am_on_step(:visa_sponsorship_application_deadline_required, change_from: :funding_type)
    expect(page).to have_no_checked_field("Yes")
    choose "No"
    and_i_click_continue

    then_i_am_on_check_answers
    expect(summary_row("Skilled Worker visas")).to have_text("Yes - can sponsor")
    expect(summary_row("Is there a visa sponsorship deadline?")).to have_text("No")
  end

  scenario "back links retrace the questions a change asked, then return to check answers" do
    given_i_have_completed_a_fee_course(can_sponsor_student_visa: false)
    when_i_change(:funding_type)
    choose "Salary"
    and_i_click_continue
    choose "Yes"
    and_i_click_continue
    then_i_am_on_step(:visa_sponsorship_application_deadline_required, change_from: :funding_type)

    click_on "Back"
    then_i_am_on_step(:skilled_worker_visa, change_from: :funding_type)

    click_on "Back"
    then_i_am_on_step(:funding_type)

    click_on "Back"
    then_i_am_on_check_answers
  end

  scenario "changing the student visa to yes asks whether there is a deadline, then its date" do
    given_i_have_completed_a_fee_course(can_sponsor_student_visa: false)
    when_i_change(:visa_sponsorship)
    choose "Yes"
    and_i_click_continue

    then_i_am_on_step(:visa_sponsorship_application_deadline_required, change_from: :visa_sponsorship)
    choose "Yes"
    and_i_click_continue

    then_i_am_on_step(:visa_sponsorship_application_deadline_at, change_from: :visa_sponsorship)
    fill_in "Day", with: visa_deadline.day
    fill_in "Month", with: visa_deadline.month
    fill_in "Year", with: visa_deadline.year
    and_i_click_continue

    then_i_am_on_check_answers
    expect(summary_row("Student visas")).to have_text("Yes - can sponsor")
  end

  scenario "changing the deadline to yes asks for its date" do
    given_i_have_completed_a_fee_course(can_sponsor_student_visa: true, deadline_required: false)
    when_i_change(:visa_sponsorship_application_deadline_required)
    choose "Yes"
    and_i_click_continue

    then_i_am_on_step(:visa_sponsorship_application_deadline_at, change_from: :visa_sponsorship_application_deadline_required)
    fill_in "Day", with: visa_deadline.day
    fill_in "Month", with: visa_deadline.month
    fill_in "Year", with: visa_deadline.year
    and_i_click_continue

    then_i_am_on_check_answers
  end

  scenario "changing the subject to physics asks about Engineers Teach Physics" do
    given_i_have_completed_a_fee_course
    when_i_change(:secondary_subjects)
    select find_or_create(:secondary_subject, :physics).subject_name, from: "First subject"
    and_i_click_continue

    then_i_am_on_step(:physics_specialisms, change_from: :secondary_subjects)
    choose "Yes"
    and_i_click_continue

    then_i_am_on_check_answers
  end

  scenario "changing the subject to modern languages asks which languages" do
    french = find_or_create(:secondary_subject, :french)
    given_i_have_completed_a_fee_course
    when_i_change(:secondary_subjects)
    select SecondarySubject.modern_languages.subject_name, from: "First subject"
    and_i_click_continue

    then_i_am_on_step(:modern_languages_specialisms, change_from: :secondary_subjects)
    check french.subject_name
    and_i_click_continue

    then_i_am_on_check_answers
    expect(page).to have_text(french.subject_name)
  end

  scenario "changing the subject to design and technology asks which specialisms" do
    given_i_have_completed_a_fee_course
    when_i_change(:secondary_subjects)
    select SecondarySubject.design_technology.subject_name, from: "First subject"
    and_i_click_continue

    then_i_am_on_step(:design_technology_specialisms, change_from: :secondary_subjects)
    specialism = page.first(".govuk-checkboxes__label").text
    check specialism, match: :first
    and_i_click_continue

    then_i_am_on_check_answers
    expect(page).to have_text(specialism)
  end

  scenario "changing from physics to another subject asks nothing more" do
    given_i_have_completed_a_fee_course(subject: :physics, campaign_name: "engineers_teach_physics")
    when_i_change(:secondary_subjects)
    select find_or_create(:secondary_subject, :mathematics).subject_name, from: "First subject"
    and_i_click_continue

    then_i_am_on_check_answers
  end

private

  def given_i_am_authenticated_as_a_provider_user
    recruitment_cycle = find_or_create(:recruitment_cycle, year: Find::CycleTimetable.current_year)
    @user = create(:user, providers: [create(:provider, :accredited_provider, recruitment_cycle:)])

    given_i_am_authenticated(user: @user)
  end

  def given_i_have_completed_a_fee_course(subject: :business_studies, campaign_name: nil, can_sponsor_student_visa: false, deadline_required: nil)
    placement_site = create(:site, :with_provider_school, provider:)
    study_site = create(:site, :study_site, provider:)
    deadline_answers = if deadline_required
                         { visa_sponsorship_application_deadline_required: true, visa_sponsorship_application_deadline_at: visa_deadline_parts }
                       elsif deadline_required == false
                         { visa_sponsorship_application_deadline_required: false }
                       else
                         {}
                       end

    wizard_state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: find_or_create(:secondary_subject, subject).id.to_s,
      campaign_name:,
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      school_uuids: [placement_site.uuid],
      study_sites_ids: [study_site.id.to_s],
      can_sponsor_student_visa:,
      start_date: "#{Date::MONTHNAMES[Date.current.month]} #{Find::CycleTimetable.current_year}",
      **deadline_answers,
    )
  end

  def when_i_change(step)
    visit wizard_path(:check_answers)

    link = page.all("a[href*='return_to_review=']").find do |candidate|
      Rack::Utils.parse_query(URI.parse(candidate[:href]).query)["return_to_review"] == step.to_s
    end
    raise "No change link for #{step}" unless link

    link.click
    then_i_am_on_step(step)
  end

  def then_i_am_on_step(step, change_from: step)
    expect(page).to have_current_path(wizard_path(step, return_to_review: change_from))
  end

  def then_i_am_on_check_answers
    expect(page).to have_current_path(wizard_path(:check_answers))
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def summary_row(key)
    page.find(".govuk-summary-list__row", text: key)
  end

  def visa_deadline
    cycle_start = provider.recruitment_cycle.application_start_date.to_date
    apply_deadline = Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_date

    [Time.zone.today, cycle_start].max.clamp(cycle_start, apply_deadline)
  end

  def visa_deadline_parts
    CourseWizard::Draft::DateParts.new(visa_deadline.year.to_s, visa_deadline.month.to_s, visa_deadline.day.to_s)
  end

  def wizard_state_store
    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    CourseWizard::StateStores::CourseWizardStore.new(repository:)
  end

  def wizard_path(step, **options)
    publish_provider_recruitment_cycle_course_wizard_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      step:,
      state_key: wizard_state_key,
      **options,
    )
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end
end
