# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add course wizard check your answers navigation", type: :system do
  before do
    FeatureFlag.activate(:wizard_add_course_flow)
    given_i_am_authenticated_as_a_provider_user(cycle_year: Date.current.year)
  end

  scenario "every TDA change-link row round-trips back to check answers" do
    given_i_have_completed_tda_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page
    then_i_see_tda_default_rows_without_change_links

    tda_changeable_steps.each do |step|
      when_i_click_change_link_for(step)
      then_i_am_on_step(step)
      and_i_complete_step_for_return(step)
      then_i_am_taken_to_the_check_answers_page
    end
  end

  scenario "every fee-branch change-link row navigates to the expected step" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_fee_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    fee_branch_changeable_steps.each do |step|
      when_i_click_change_link_for(step)
      then_i_am_on_step(step)
      when_i_visit_check_answers_page
      then_i_am_taken_to_the_check_answers_page
    end
  end

  scenario "every salary-branch change-link row navigates to the expected step" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_salary_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    salary_branch_changeable_steps.each do |step|
      when_i_click_change_link_for(step)
      then_i_am_on_step(step)
      when_i_visit_check_answers_page
      then_i_am_taken_to_the_check_answers_page
    end
  end

  scenario "changing qualification branch and updating returns to check answers" do
    given_i_have_completed_tda_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    when_i_click_change_link_for(:qualifications)
    then_i_am_on_step(:qualifications)
    choose "QTS"
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:funding_type)
    choose "Fee - no salary"
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:study_pattern)
    check "Full time"
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:schools)
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:study_sites)
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:visa_sponsorship)
    choose "No"
    and_i_click_continue

    then_i_am_on_step_without_return_to_review(:start_date)
    and_i_click_continue

    then_i_am_taken_to_the_check_answers_page
    then_i_see_updated_branch_values
  end

  scenario "shows fee-branch rows including accredited provider and visa sponsorship" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_fee_wizard_state

    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page
    then_i_see_fee_branch_check_answers_rows
  end

  scenario "shows skilled worker visa row on salary branch" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_salary_wizard_state

    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page
    then_i_see_salary_branch_check_answers_rows
  end

  scenario "TDA flow still shows the skilled worker visa default row when study sites are skipped" do
    given_the_provider_has_no_study_sites
    given_i_have_completed_tda_wizard_state_without_study_sites
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_text("Funding type")
    expect(page).to have_text("Study pattern")
    expect(page).to have_text("Skilled Worker visas")
    expect(page).to have_text("No - cannot sponsor")
  end

  scenario "shows add a study site call to action when provider has no study sites" do
    given_the_provider_has_no_study_sites
    given_i_have_completed_fee_wizard_state_without_study_sites
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_link("Add a study site")
  end

  scenario "creates a course from secondary fee branch with mapped attributes" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_fee_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect { and_i_click_add_course }.to change { provider.courses.count }.by(1)

    created_course = provider.courses.order(:created_at).last
    visa_deadline = expected_visa_deadline_date
    expect(created_course.funding).to eq("fee")
    expect(created_course.study_mode).to eq("full_time")
    expect(created_course.accredited_provider_code).to eq(partner_provider_code)
    expect(created_course.can_sponsor_student_visa).to be(true)
    expect(created_course.can_sponsor_skilled_worker_visa).to be(false)
    expect(created_course.visa_sponsorship_application_deadline_at.to_date).to eq(visa_deadline)
  end

  scenario "creates a course from secondary salary branch with mapped attributes" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_salary_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect { and_i_click_add_course }.to change { provider.courses.count }.by(1)

    created_course = provider.courses.order(:created_at).last
    visa_deadline = expected_visa_deadline_date
    expect(created_course.funding).to eq("salary")
    expect(created_course.study_mode).to eq("full_time")
    expect(created_course.accredited_provider_code).to eq(partner_provider_code)
    expect(created_course.can_sponsor_student_visa).to be(false)
    expect(created_course.can_sponsor_skilled_worker_visa).to be(true)
    expect(created_course.visa_sponsorship_application_deadline_at.to_date).to eq(visa_deadline)
  end

  scenario "further education flow renders expected rows and creates successfully" do
    given_i_have_completed_further_education_wizard_state
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_text("Subject level")
    expect(page).to have_text("Further education")
    expect(page).to have_text("Qualification")
    expect(page).to have_text("PGDE only (without QTS)")
    expect(page).to have_text("Funding type")
    expect(page).to have_text("Fee - no salary")
    expect(page).to have_text("Study pattern")
    expect(page).to have_text("Full time")
    expect(page).to have_no_text("Subjects")
    expect(page).to have_no_text("Accredited provider")
    expect(page).to have_no_text("Student visas")
    expect(page).to have_no_text("Skilled Worker visas")
    expect(page).to have_no_text("Visa sponsorship deadline")

    expect { and_i_click_add_course }.to change { provider.courses.count }.by(1)
    created_course = provider.courses.order(:created_at).last
    expect(created_course.level).to eq("further_education")
    expect(created_course.qualification).to eq("pgde")
    expect(created_course.funding).to eq("fee")
    expect(created_course.study_mode).to eq("full_time")
  end

  scenario "shows SEND yes row when is_send is true" do
    given_i_have_completed_tda_wizard_state_with_send_yes
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_text("Special educational needs and disability (SEND)")
    expect(page).to have_text("Yes")
  end

  scenario "shows accredited provider row without change link when selection step is skipped" do
    given_i_have_completed_secondary_fee_wizard_state_with_single_partner
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_text("Accredited provider")
    expect(page).to have_text(provider.accredited_partners.first.provider_name)
    expect(page).to have_no_selector("a[href*='return_to_review=accredited_provider']")
  end

  scenario "shows visa deadline question as no and hides date row when deadline step is skipped" do
    given_i_am_authenticated_as_school_provider_with_partners(cycle_year: Date.current.year)
    given_i_have_completed_secondary_fee_wizard_state_with_no_visa_deadline
    when_i_visit_check_answers_page
    then_i_am_taken_to_the_check_answers_page

    expect(page).to have_text("Is there a visa sponsorship deadline?")
    expect(page).to have_text("No")
    expect(page).to have_no_text("Visa sponsorship deadline")
  end

private

  def tda_changeable_steps
    %i[
      primary_subjects
      age_range
      qualifications
      schools
      study_sites
      start_date
    ]
  end

  def fee_branch_changeable_steps
    %i[
      secondary_subjects
      age_range
      qualifications
      funding_type
      study_pattern
      schools
      study_sites
      accredited_provider
      visa_sponsorship
      visa_sponsorship_application_deadline_required
      visa_sponsorship_application_deadline_at
      start_date
    ]
  end

  def salary_branch_changeable_steps
    %i[
      secondary_subjects
      age_range
      qualifications
      funding_type
      study_pattern
      schools
      study_sites
      accredited_provider
      skilled_worker_visa
      visa_sponsorship_application_deadline_required
      visa_sponsorship_application_deadline_at
      start_date
    ]
  end

  def given_i_am_authenticated_as_a_provider_user(cycle_year:)
    recruitment_cycle = find_or_create(:recruitment_cycle, year: cycle_year)

    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, recruitment_cycle:),
      ],
    )

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_school_provider_with_partners(cycle_year:)
    recruitment_cycle = find_or_create(:recruitment_cycle, year: cycle_year)
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      recruitment_cycle:,
      sites: [build(:site), build(:site, :study_site)],
    )
    first_partner = create(:accredited_provider, recruitment_cycle:)
    second_partner = create(:accredited_provider, recruitment_cycle:)
    create(:provider_partnership, training_provider: school_provider, accredited_provider: first_partner)
    create(:provider_partnership, training_provider: school_provider, accredited_provider: second_partner)

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def provider
    @provider ||= @user.providers.first
  end

  def wizard_state_key
    @wizard_state_key ||= SecureRandom.uuid
  end

  def given_the_provider_has_no_study_sites
    provider.study_sites.destroy_all
    @placement_site = provider.sites.first || create(:site, provider:)
    expect(provider.reload.study_sites).to be_empty
  end

  def given_i_have_completed_tda_wizard_state
    primary_subject = find_or_create(:primary_subject, :primary)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      is_send: "false",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "undergraduate_degree_with_qts",
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
      can_sponsor_student_visa: false,
      visa_sponsorship_application_deadline_required: false,
    )
  end

  def given_i_have_completed_tda_wizard_state_without_study_sites
    primary_subject = find_or_create(:primary_subject, :primary)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      is_send: "false",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "undergraduate_degree_with_qts",
      site_ids: [@placement_site.id.to_s],
      study_sites_ids: [],
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
      can_sponsor_student_visa: false,
      visa_sponsorship_application_deadline_required: false,
    )
  end

  def given_i_have_completed_fee_wizard_state_without_study_sites
    primary_subject = find_or_create(:primary_subject, :primary)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      is_send: "false",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [@placement_site.id.to_s],
      study_sites_ids: [],
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
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

  def partner_provider_code
    provider.accredited_partners.first.provider_code
  end

  def then_i_am_taken_to_the_check_answers_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step: :check_answers,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
    expect(page).to have_content("Check your answers")
  end

  def when_i_click_change_link_for(step)
    link = page.all("a[href*='return_to_review=']").find do |candidate|
      href = candidate[:href].to_s
      query = URI.parse(href).query.to_s
      Rack::Utils.parse_nested_query(query)["return_to_review"] == step.to_s
    rescue URI::InvalidURIError
      false
    end

    raise "No change link found for #{step}" if link.nil?

    link.click
  end

  def then_i_am_on_step(step)
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step:,
        state_key: wizard_state_key,
        return_to_review: step,
      ),
      ignore_query: false,
    )
  end

  def then_i_am_on_step_without_return_to_review(step)
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_wizard_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: provider.recruitment_cycle_year,
        step:,
        state_key: wizard_state_key,
      ),
      ignore_query: true,
    )
  end

  def and_i_complete_step_for_return(step)
    case step
    when :visa_sponsorship_application_deadline_required
      choose "No"
    end

    and_i_click_continue
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_click_add_course
    click_on "Add course"
  end

  def current_cycle_current_month_label(cycle_year:)
    "#{Date::MONTHNAMES[Date.current.month]} #{cycle_year}"
  end

  def then_i_see_updated_branch_values
    expect(page).to have_text("Qualification")
    expect(page).to have_text("QTS")
    expect(page).to have_text("Funding type")
    expect(page).to have_text("Fee - no salary")
    expect(page).to have_text("Study pattern")
    expect(page).to have_text("Full time")
    expect(page).to have_text("Student visas")
    expect(page).to have_text("No - cannot sponsor")
  end

  def then_i_see_tda_default_rows_without_change_links
    expect(page).to have_text("Funding type")
    expect(page).to have_text("Salary (apprenticeship)")
    expect(page).to have_text("Study pattern")
    expect(page).to have_text("Full time")
    expect(page).to have_text("Skilled Worker visas")
    expect(page).to have_text("No - cannot sponsor")
    expect(page).to have_no_selector("a[href*='return_to_review=funding_type']")
    expect(page).to have_no_selector("a[href*='return_to_review=study_pattern']")
    expect(page).to have_no_selector("a[href*='return_to_review=skilled_worker_visa']")

    rendered_text = page.text.gsub(/\s+/, " ")
    expect(rendered_text.index("Study site")).to be < rendered_text.index("Skilled Worker visas")
  end

  def given_i_have_completed_secondary_fee_wizard_state
    physics = find_or_create(:secondary_subject, :physics)
    business = find_or_create(:secondary_subject, :business_studies)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: physics.id.to_s,
      subordinate_subject_id: business.id.to_s,
      campaign_name: "engineers_teach_physics",
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      accredited_provider_code: partner_provider_code,
      can_sponsor_student_visa: true,
      visa_sponsorship_application_deadline_required: true,
      visa_sponsorship_application_deadline_at: visa_deadline_date_parts,
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
    )
  end

  def given_i_have_completed_secondary_salary_wizard_state
    physics = find_or_create(:secondary_subject, :physics)
    business = find_or_create(:secondary_subject, :business_studies)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )

    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: physics.id.to_s,
      subordinate_subject_id: business.id.to_s,
      campaign_name: "engineers_teach_physics",
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "salary",
      study_pattern: %w[full_time],
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      accredited_provider_code: partner_provider_code,
      can_sponsor_skilled_worker_visa: true,
      visa_sponsorship_application_deadline_required: true,
      visa_sponsorship_application_deadline_at: visa_deadline_date_parts,
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
    )
  end

  def given_i_have_completed_further_education_wizard_state
    further_education_subject = find_or_create(:further_education_subject)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "further_education",
      is_send: "false",
      age_range_in_years: "14_to_19",
      qualification: "pgde",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
      can_sponsor_student_visa: false,
      primary_master_subject_id: nil,
      secondary_master_subject_id: nil,
      subordinate_subject_id: nil,
      master_subject_id: further_education_subject.id.to_s,
      subject_ids: [further_education_subject.id.to_s],
    )
  end

  def given_i_have_completed_tda_wizard_state_with_send_yes
    primary_subject = find_or_create(:primary_subject, :primary)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "primary",
      is_send: "true",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "undergraduate_degree_with_qts",
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
      can_sponsor_student_visa: false,
      visa_sponsorship_application_deadline_required: false,
    )
  end

  def given_i_have_completed_secondary_fee_wizard_state_with_single_partner
    given_i_am_authenticated_as_school_provider_with_single_partner(cycle_year: Date.current.year)
    physics = find_or_create(:secondary_subject, :physics)
    business = find_or_create(:secondary_subject, :business_studies)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: physics.id.to_s,
      subordinate_subject_id: business.id.to_s,
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      can_sponsor_student_visa: true,
      visa_sponsorship_application_deadline_required: false,
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
    )
  end

  def given_i_have_completed_secondary_fee_wizard_state_with_no_visa_deadline
    physics = find_or_create(:secondary_subject, :physics)
    business = find_or_create(:secondary_subject, :business_studies)
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    repository = CourseWizard::Repositories::Course.new(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      state_key: wizard_state_key,
      expires_in: 24.hours,
    )
    state_store = CourseWizard::StateStores::CourseWizardStore.new(repository:)
    state_store.write(
      level: "secondary",
      is_send: "false",
      secondary_master_subject_id: physics.id.to_s,
      subordinate_subject_id: business.id.to_s,
      campaign_name: "engineers_teach_physics",
      age_range_in_years: "11_to_16",
      qualification: "qts",
      funding_type: "fee",
      study_pattern: %w[full_time],
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
      accredited_provider_code: partner_provider_code,
      can_sponsor_student_visa: true,
      visa_sponsorship_application_deadline_required: false,
      visa_sponsorship_application_deadline_at: nil,
      start_date: current_cycle_current_month_label(cycle_year: Date.current.year),
    )
  end

  def given_i_am_authenticated_as_school_provider_with_single_partner(cycle_year:)
    recruitment_cycle = find_or_create(:recruitment_cycle, year: cycle_year)
    school_provider = create(
      :provider,
      provider_type: :lead_school,
      recruitment_cycle:,
      sites: [build(:site), build(:site, :study_site)],
    )
    single_partner = create(:accredited_provider, recruitment_cycle:)
    create(:provider_partnership, training_provider: school_provider, accredited_provider: single_partner)

    @user = create(:user, providers: [school_provider])
    given_i_am_authenticated(user: @user)
  end

  def then_i_see_fee_branch_check_answers_rows
    expect(page).to have_text("Subject level")
    expect(page).to have_text("Special educational needs and disability (SEND)")
    expect(page).to have_text("Subjects")
    expect(page).to have_text("Engineers Teach Physics")
    expect(page).to have_text("Age range")
    expect(page).to have_text("Qualification")
    expect(page).to have_text("Funding type")
    expect(page).to have_text("Study pattern")
    expect(page).to have_text("Placement school")
    expect(page).to have_text("Study site")
    expect(page).to have_text("Accredited provider")
    expect(page).to have_text("Student visas")
    expect(page).to have_text("Is there a visa sponsorship deadline?")
    expect(page).to have_text("Visa sponsorship deadline")
    expect(page).to have_text("Course start date")
  end

  def then_i_see_salary_branch_check_answers_rows
    expect(page).to have_text("Subject level")
    expect(page).to have_text("Subjects")
    expect(page).to have_text("Engineers Teach Physics")
    expect(page).to have_text("Funding type")
    expect(page).to have_text("Skilled Worker visas")
    expect(page).to have_text("Is there a visa sponsorship deadline?")
    expect(page).to have_text("Visa sponsorship deadline")
  end

  def expected_visa_deadline_date
    today = Time.zone.today
    cycle_start = provider.recruitment_cycle.application_start_date.to_date
    cycle_apply_deadline = Find::CycleTimetable.date(:apply_deadline, provider.recruitment_cycle_year).to_date

    [today, cycle_start].max.clamp(cycle_start, cycle_apply_deadline)
  end

  def visa_deadline_date_parts
    date = expected_visa_deadline_date
    CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts.new(
      date.year.to_s,
      date.month.to_s,
      date.day.to_s,
    )
  end
end
