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

    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page

    when_i_choose_the_applications_open_date
    and_i_choose_the_first_start_date
    then_i_am_on_the_check_your_answers_page
    and_i_can_not_change_funding_type
    and_i_can_not_change_study_mode
    and_i_can_not_change_visa_requirements
    then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved

    when_i_click_on_the_course_i_created
    then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship_on_basic_details

    when_i_click_on_the_course_description_tab
    then_i_do_not_see_the_degree_requirements_row
    and_i_do_not_see_the_change_link_for_course_length

    given_i_fill_in_all_other_fields_for_the_course
    when_i_publish_the_course
    then_the_course_is_published
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
    and_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved

    when_i_click_on_the_course_i_created
    then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship_on_basic_details

    when_i_click_on_the_course_description_tab
    then_i_do_not_see_the_degree_requirements_row
    and_i_do_not_see_the_change_link_for_course_length

    given_i_fill_in_all_other_fields_for_the_course
    when_i_publish_the_course
    then_the_course_is_published
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
    and_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved

    when_i_click_on_the_course_i_created
    then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship_on_basic_details

    when_i_click_on_the_course_description_tab
    then_i_do_not_see_the_degree_requirements_row
    and_i_do_not_see_the_change_link_for_course_length

    given_i_fill_in_all_other_fields_for_the_course
    when_i_publish_the_course
    then_the_course_is_published
  end

  scenario 'do not show teacher degree apprenticeship for further education' do
    given_i_am_authenticated_as_a_school_direct_provider_user
    and_the_tda_feature_flag_is_active
    when_i_visit_the_courses_page
    and_i_click_on_add_course
    and_i_choose_a_further_education_course
    then_i_am_on_the_qualifications_page
    and_i_do_not_see_the_degree_awarding_option
  end

  scenario 'back links when choosing a teacher degree apprenticeship' do
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
    and_the_back_link_points_to_outcome_page

    when_i_choose_the_school
    then_the_back_link_points_to_the_school_page
    and_i_choose_the_study_site
    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page
    and_the_back_link_points_to_the_study_site_page

    when_i_choose_the_applications_open_date
    and_the_back_link_points_to_applications_open_date_page
    and_i_choose_the_first_start_date
    and_the_back_link_points_to_start_date_page
    then_i_am_on_the_check_your_answers_page
  end

  scenario 'creating a tda course then changing it to a non tda fee paying course' do
    given_i_am_on_the_check_answers_page_of_a_new_tda_course
    when_i_visit_the_course_outcome_page
    and_i_choose_qts
    and_i_choose_fee
    and_i_choose_part_time
    and_i_choose_to_sponsor_a_student_visa
    when_i_click_on_add_a_course
    then_i_see_the_correct_attributes_in_the_database_for_fee_paying
  end

  scenario 'creating a tda course then changing it to a non tda salaried course' do
    given_i_am_on_the_check_answers_page_of_a_new_tda_course
    when_i_visit_the_course_outcome_page
    and_i_choose_qts
    and_i_choose_salaried
    and_i_choose_part_time
    and_i_choose_to_sponsor_a_skilled_worker_visa
    when_i_click_on_add_a_course
    then_i_see_the_correct_attributes_in_the_database_for_salaried
  end

  def given_i_am_authenticated_as_a_school_direct_provider_user
    recruitment_cycle = create(:recruitment_cycle, year: 2025)
    @user = create(:user, providers: [build(:provider, recruitment_cycle:, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    @provider = @user.providers.first
    create(:provider, :accredited_provider, provider_code: '1BJ')
    @accredited_provider = create(:provider, :accredited_provider, provider_code: '1BJ', recruitment_cycle:)
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

  def and_i_choose_a_further_education_course
    choose 'Further education'
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

  def then_i_am_on_the_qualifications_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_courses_outcome_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def and_i_do_not_see_the_degree_awarding_option
    expect(
      publish_courses_new_outcome_page.qualification_fields.has_undergraduate_degree_with_qts?
    ).to be false
  end

  def when_i_choose_a_degree_awarding_qualification
    choose 'Teacher degree apprenticeship (TDA) with QTS'
    and_i_click_continue
  end

  def then_i_am_on_the_choose_schools_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_courses_schools_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def and_the_back_link_points_to_outcome_page
    expect(publish_courses_new_outcome_page.back_link[:href]).to include(new_publish_provider_recruitment_cycle_courses_outcome_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025))
  end

  def when_i_choose_the_school
    check provider.sites.first.location_name
    and_i_click_continue
  end

  def then_the_back_link_points_to_the_school_page
    expect(publish_courses_new_study_sites_page.back_link[:href]).to include(back_publish_provider_recruitment_cycle_courses_schools_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025))
  end

  def and_i_choose_the_study_site
    check provider.study_sites.first.location_name
    and_i_click_continue
  end

  def and_the_back_link_points_to_the_study_site_page
    expect(publish_courses_new_applications_open_page.back_link[:href]).to include(back_publish_provider_recruitment_cycle_courses_study_sites_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025))
  end

  def then_i_am_on_the_add_applications_open_date_page
    expect(page).to have_current_path(new_publish_provider_recruitment_cycle_courses_applications_open_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025), ignore_query: true)
  end

  def and_the_back_link_points_to_applications_open_date_page
    expect(publish_courses_new_start_date_page.back_link[:href]).to include(new_publish_provider_recruitment_cycle_courses_applications_open_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025))
  end

  def when_i_choose_the_applications_open_date
    first('input.govuk-radios__input').set(true)
    and_i_click_continue
  end

  def and_i_choose_the_first_start_date
    first('input.govuk-radios__input').set(true)
    and_i_click_continue
  end

  def and_the_back_link_points_to_start_date_page
    expect(publish_course_confirmation_page.back_link[:href]).to include(new_publish_provider_recruitment_cycle_courses_start_date_path(provider_code: provider.provider_code, recruitment_cycle_year: 2025))
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
    expect(course.additional_degree_subject_requirements).to be(false)
    expect(course.degree_subject_requirements).to eq('f')
    expect(course.degree_grade).to eq('not_required')
    expect(course.enrichments.last).to be_present
    expect(course.enrichments.last.course_length).to eq('4 years')
  end

  def and_i_select_no_send
    publish_courses_new_level_page.send_fields.is_send_false.click
  end

  def then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship
    within('[data-qa="course__study_mode"]') do
      expect(page).to have_no_link('Change')
    end

    within('[data-qa="course__funding_type"]') do
      expect(page).to have_no_link('Change')
    end

    within('[data-qa="course__skilled_worker_visa_sponsorship"]') do
      expect(page).to have_no_link('Change')
    end
  end

  def then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship_on_basic_details
    within('[data-qa="course__study_mode"]') do
      expect(page).to have_no_link('Change')
    end

    within('[data-qa="course__funding"]') do
      expect(page).to have_no_link('Change')
    end

    within('[data-qa="course__can_sponsor_skilled_worker_visa"]') do
      expect(page).to have_no_link('Change')
    end
  end

  def and_i_do_not_see_the_change_link_for_course_length
    within('[data-qa="enrichment__course_length"]') do
      expect(page).to have_no_link('Change')
    end
  end

  def when_i_click_on_the_course_i_created
    click_on course_name_and_code
    when_i_click_on_the_course_basic_details_tab
  end

  def when_i_click_on_the_course_basic_details_tab
    publish_provider_courses_show_page.basic_details_link.click
  end

  def when_i_click_on_the_course_description_tab
    publish_provider_courses_show_page.description_link.click
  end

  def then_i_do_not_see_the_degree_requirements_row
    expect(publish_provider_courses_show_page).not_to have_degree
  end

  def given_i_fill_in_all_other_fields_for_the_course
    and_i_add_course_details
    and_i_add_salary_information
    and_i_add_gcse_requirements
  end

  def and_i_add_course_details
    publish_provider_courses_show_page.about_course.find_link(
      text: 'Change details about this course'
    ).click

    fill_in 'About this course', with: 'Details about this course'
    click_on 'Update about this course'

    publish_provider_courses_show_page.how_school_placements_work.find_link(
      text: 'Change details about how school placements work'
    ).click

    fill_in 'How school placements work', with: 'School placements information'
    click_on 'Update how school placements work'
  end

  def and_i_add_salary_information
    publish_provider_courses_show_page.salary_details.find_link(text: 'Change salary').click
    publish_course_salary_edit_page.salary_details.set('Some salary details')
    publish_course_salary_edit_page.submit.click
  end

  def and_i_add_gcse_requirements
    publish_provider_courses_show_page.gcse.find_link(
      text: 'Enter GCSE and equivalency test requirements'
    ).click
    publish_courses_gcse_requirements_page.pending_gcse_yes_radio.click
    publish_courses_gcse_requirements_page.gcse_equivalency_yes_radio.click
    publish_courses_gcse_requirements_page.english_equivalency.check
    publish_courses_gcse_requirements_page.maths_equivalency.check
    publish_courses_gcse_requirements_page.additional_requirements.set('Some Proficiency')
    publish_courses_gcse_requirements_page.save.click
  end

  def when_i_publish_the_course
    publish_provider_courses_show_page.course_button_panel.publish_button.click
  end

  def then_the_course_is_published
    expect(publish_provider_courses_show_page.errors.map(&:text)).to eq([])
    expect(page).to have_content('Your course has been published.')
    expect(course.content_status).to be :published
  end

  def provider
    @user.providers.first
  end

  def course
    provider.courses.last
  end

  def course_name_and_code
    course.decorate.name_and_code
  end

  def given_i_am_on_the_check_answers_page_of_a_new_tda_course
    given_i_am_authenticated_as_a_school_direct_provider_user
    and_the_tda_feature_flag_is_active
    and_i_visit_the_courses_page
    and_i_click_on_add_course
    and_i_choose_a_secondary_course
    and_i_select_a_subject
    and_i_choose_an_age_range
    and_i_choose_a_degree_awarding_qualification
    and_i_choose_the_school
    and_i_choose_the_study_site
    and_i_choose_the_applications_open_date
    and_i_choose_the_first_start_date
    then_i_am_on_the_check_your_answers_page
  end

  def when_i_visit_the_course_outcome_page
    publish_course_confirmation_page.details.outcome.change_link.click
  end

  def and_i_choose_qts
    publish_courses_outcome_edit_page.qts.choose
    and_i_click_continue
  end

  def and_i_choose_fee
    choose 'Fee - no salary'
    and_i_click_continue
  end

  def and_i_choose_salaried
    choose 'Salary'
    and_i_click_continue
  end

  def and_i_choose_part_time
    uncheck 'Full time'
    check 'Part time'
    and_i_click_continue
  end

  def and_i_choose_to_sponsor_a_student_visa
    choose 'Yes'
    and_i_click_continue
  end

  def and_i_choose_to_sponsor_a_skilled_worker_visa
    choose('course_can_sponsor_skilled_worker_visa_true')
    and_i_click_continue
  end

  def then_i_see_the_correct_attributes_in_the_database_for_fee_paying
    course.reload
    expect(course.study_mode == 'part_time').to be(true)
    expect(course.funding_type == 'fee').to be(true)
    expect(course.can_sponsor_skilled_worker_visa == false).to be(true)
    expect(course.can_sponsor_student_visa == true).to be(true)
  end

  def then_i_see_the_correct_attributes_in_the_database_for_salaried
    course.reload
    expect(course.study_mode == 'part_time').to be(true)
    expect(course.funding_type == 'salary').to be(true)
    expect(course.can_sponsor_skilled_worker_visa == true).to be(true)
    expect(course.can_sponsor_student_visa == false).to be(true)
  end

  alias_method :and_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship, :then_i_do_not_see_the_change_links_for_study_mode_funding_type_and_visa_sponsorship
  alias_method :and_i_visit_the_courses_page, :when_i_visit_the_courses_page
  alias_method :and_i_choose_a_degree_awarding_qualification, :when_i_choose_a_degree_awarding_qualification
  alias_method :and_i_choose_the_school, :when_i_choose_the_school
  alias_method :and_i_choose_the_applications_open_date, :when_i_choose_the_applications_open_date
  alias_method :and_i_am_on_the_check_your_answers_page, :then_i_am_on_the_check_your_answers_page
end
