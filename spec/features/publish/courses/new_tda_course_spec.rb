# frozen_string_literal: true

require 'rails_helper'

feature 'Adding a teacher degree apprenticeship course', :can_edit_current_and_next_cycles do
  scenario 'creating a degree awarding course from school direct provider' do
    given_i_am_authenticated_as_a_school_direct_provider_user
    and_the_tda_feature_flag_is_active
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    and_i_choose_a_secondary_course
    and_i_select_a_subject
    and_i_choose_an_age_range
    then_i_see_the_degree_awarding_option

    when_i_choose_a_degree_awarding_qualification

    # We skip the pages for the TDA: funding type, part-time/full time
    then_i_am_on_the_choose_schools_page

    when_i_choose_the_school
    and_i_choose_the_study_site

    then_i_am_on_the_accreddited_provider_page

    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page

    when_i_choose_the_applications_open_date
    and_i_choose_the_first_start_date
    then_i_am_on_the_check_your_answers_page
    and_i_can_not_change_funding_type
    and_i_can_not_change_study_mode
    and_i_can_not_change_visa_requirements

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved
  end

  scenario 'creating a degree awarding course from scitt provider' do
    given_i_am_authenticated_as_a_scitt_provider_user
    and_the_tda_feature_flag_is_active
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    and_i_choose_a_secondary_course
    and_i_select_a_subject
    and_i_choose_an_age_range
    then_i_see_the_degree_awarding_option

    when_i_choose_a_degree_awarding_qualification
    # We skip the pages for the TDA: funding type, part-time/full time
    then_i_am_on_the_choose_schools_page

    when_i_choose_the_school
    and_i_choose_the_study_site
    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page

    when_i_choose_the_applications_open_date
    and_i_choose_the_first_start_date
    then_i_am_on_the_check_your_answers_page

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved
  end

  scenario 'when choosing primary course' do
    given_i_am_authenticated_as_a_school_direct_provider_user
    and_the_tda_feature_flag_is_active
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    and_i_choose_a_primary_course
    and_i_choose_a_primary_age_range
    then_i_see_the_degree_awarding_option

    when_i_choose_a_degree_awarding_qualification
    # We skip the pages for the TDA: funding type, part-time/full time
    then_i_am_on_the_choose_schools_page

    when_i_choose_the_school
    and_i_choose_the_study_site
    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page

    when_i_choose_the_applications_open_date
    and_i_choose_the_first_start_date
    then_i_am_on_the_check_your_answers_page

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved
  end

  def given_i_am_authenticated_as_a_school_direct_provider_user
    recruitment_cycle = create(:recruitment_cycle, year: 2025)
    @user = create(:user, providers: [build(:provider, recruitment_cycle:, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    @provider = @user.providers.first
    @accredited_provider = create(:provider, :accredited_provider, recruitment_cycle:)
    @provider.accrediting_provider_enrichments = []
    @provider.accrediting_provider_enrichments << AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: @accredited_provider.provider_code,
        Description: 'description'
      }
    )
    @provider.save

    given_i_am_authenticated(user: @user)
  end

  def given_i_am_authenticated_as_a_scitt_provider_user
    @user = create(
      :user,
      providers: [
        create(:provider, :scitt, recruitment_cycle: build(:recruitment_cycle, year: 2025), sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])
      ]
    )
    given_i_am_authenticated(
      user: @user
    )
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def when_i_visit_the_courses_page
    publish_provider_courses_index_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def and_i_click_on_add_course
    click_on 'Add course'
    and_i_click_continue
  end

  def and_i_choose_a_secondary_course
    choose 'Secondary'
    and_i_select_no_send
    and_i_click_continue
  end

  def and_i_choose_a_primary_course
    choose 'Primary'
    and_i_select_no_send
    and_i_click_continue
    choose 'Primary with English'
    and_i_click_continue
  end

  def and_i_select_a_subject
    select 'Dance', from: 'First subject'
    and_i_click_continue
  end

  def and_i_choose_an_age_range
    choose '14 to 19'
    and_i_click_continue
  end

  def and_i_choose_a_primary_age_range
    choose '3 to 7'
    and_i_click_continue
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def then_i_see_the_degree_awarding_option
    expect(
      publish_courses_new_outcome_page.qualification_fields.has_undergraduate_degree_with_qts?
    ).to be true
    expect(publish_courses_new_outcome_page.qualification_fields.text).to include(
      'Teacher degree apprenticeship (TDA) with QTS'
    )
  end

  def when_i_choose_a_degree_awarding_qualification
    choose 'Teacher degree apprenticeship (TDA) with QTS'
    and_i_click_continue
  end

  def then_i_am_on_the_choose_schools_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_courses_schools_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def when_i_choose_the_school
    check provider.sites.first.location_name
    and_i_click_continue
  end

  def and_i_choose_the_study_site
    check provider.study_sites.first.location_name
    and_i_click_continue
  end

  def then_i_am_on_the_accreddited_provider_page; end

  def then_i_am_on_the_add_applications_open_date_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_courses_applications_open_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def when_i_choose_the_applications_open_date
    first('input.govuk-radios__input').set(true)
    and_i_click_continue
  end

  def and_i_choose_the_first_start_date
    first('input.govuk-radios__input').set(true)
    and_i_click_continue
  end

  def then_i_am_on_the_check_your_answers_page
    expect(page).to have_current_path(confirmation_publish_provider_recruitment_cycle_courses_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def and_i_can_not_change_funding_type
    expect(
      publish_course_confirmation_page.details.funding_type.value.text
    ).to eq('Teaching apprenticeship - with salary')

    expect(
      publish_course_confirmation_page.details.funding_type.text
    ).not_to include('Change')
  end

  def and_i_can_not_change_study_mode
    expect(
      publish_course_confirmation_page.details.study_mode.value.text
    ).to eq('Full time')

    expect(
      publish_course_confirmation_page.details.study_mode.text
    ).not_to include('Change')
  end

  def and_i_can_not_change_visa_requirements
    expect(
      publish_course_confirmation_page.details.skilled_visa_requirements.value.text
    ).to eq('No - cannot sponsor')

    expect(
      publish_course_confirmation_page.details.skilled_visa_requirements.text
    ).not_to include('Change')
  end

  def when_i_click_on_add_a_course
    click_on 'Add course'
  end

  def then_the_tda_course_is_created
    expect(course.undergraduate_degree_with_qts?).to be(true)
  end

  def and_the_tda_defaults_are_saved
    expect(course.program_type).to eq('teacher_degree_apprenticeship')
    expect(course.funding_type).to eq('apprenticeship')
    expect(course.can_sponsor_student_visa?).to be false
    expect(course.can_sponsor_skilled_worker_visa?).to be false
  end

  def and_i_select_no_send
    publish_courses_new_level_page.send_fields.is_send_false.click
  end

  def provider
    @user.providers.first
  end

  def course
    provider.courses.last
  end
end