# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course outcome', { can_edit_current_and_next_cycles: false } do
  scenario 'i can update the course outcome' do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_qts_course_i_want_to_edit
    when_i_visit_the_course_outcome_page
    and_i_update_the_course_outcome
    and_i_submit
    then_i_should_see_a_success_message
    and_the_course_outcome_is_updated
    and_i_should_be_on_the_course_details_page
  end

  context 'a course offering QTS' do
    scenario 'shows the correct outcome options to choose from' do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page
      then_i_am_shown_the_correct_qts_options
    end
  end

  context 'a further education course not offering QTS' do
    scenario 'shows the correct outcome options to choose from' do
      given_i_am_authenticated_as_a_provider_user
      and_there_is_a_non_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page
      then_i_am_shown_the_correct_non_qts_options
    end
  end

  context 'TDA course with db_backed_funding_type enabled' do
    scenario 'changing the outcome from non TDA to TDA' do
      given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
      and_the_tda_feature_flag_is_active
      and_the_db_backed_funding_type_feature_flag_is_enabled
      and_there_is_a_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page_in_the_next_cycle
      and_i_choose_undergraduate_degree_with_qts
      and_the_degree_type_is_postgraduate
      and_i_submit
      then_the_default_options_for_a_tda_course_should_be_applied
    end

    context 'fee course' do
      scenario 'changing the outcome from TDA to non TDA' do
        given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
        and_the_tda_feature_flag_is_active
        and_the_db_backed_funding_type_feature_flag_is_enabled
        and_there_is_a_tda_course_i_want_to_edit
        when_i_visit_the_course_outcome_page_in_the_next_cycle
        and_the_degree_type_is_undergraduate
        and_i_choose_qts
        and_the_degree_type_is_postgraduate
        and_the_back_link_points_to_the_outcome_page
        and_i_choose_the_fee_paying
        and_the_back_link_points_to_the_funding_type_page
        and_i_choose_part_time
        and_the_back_link_points_to_the_study_mode_page

        and_i_click_back
        then_i_am_on_the_study_mode_page

        and_i_click_back
        then_i_am_on_the_funding_type_page

        when_i_update
        and_i_update

        and_i_choose_to_sponsor_a_student_visa
        then_i_see_the_correct_attributes_in_the_database_for_fee_paying
      end
    end

    context 'salaried course' do
      scenario 'changing the outcome from TDA to non TDA' do
        given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
        and_the_tda_feature_flag_is_active
        and_the_db_backed_funding_type_feature_flag_is_enabled
        and_there_is_a_tda_course_i_want_to_edit
        when_i_visit_the_course_outcome_page_in_the_next_cycle
        and_the_degree_type_is_undergraduate
        and_i_choose_qts
        and_the_degree_type_is_postgraduate
        and_the_back_link_points_to_the_outcome_page
        and_i_choose_salaried
        and_the_back_link_points_to_the_funding_type_page
        and_i_choose_part_time
        and_the_back_link_points_to_the_study_mode_page
        and_i_choose_to_sponsor_a_skilled_worker_visa
        then_i_see_the_correct_attributes_in_the_database_for_salaried
      end
    end
  end

  context 'TDA course with db_backed_funding_type_disabled' do
    scenario 'changing the outcome from non TDA to TDA' do
      given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
      and_the_tda_feature_flag_is_active
      and_the_db_backed_funding_type_feature_flag_is_disabled
      and_there_is_a_qts_course_i_want_to_edit
      when_i_visit_the_course_outcome_page_in_the_next_cycle
      and_i_choose_undergraduate_degree_with_qts
      and_the_degree_type_is_postgraduate
      and_i_submit
      then_the_default_options_for_a_tda_course_should_be_applied
    end

    context 'fee course' do
      scenario 'changing the outcome from TDA to non TDA' do
        given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
        and_the_tda_feature_flag_is_active
        and_the_db_backed_funding_type_feature_flag_is_disabled
        and_there_is_a_tda_course_i_want_to_edit
        when_i_visit_the_course_outcome_page_in_the_next_cycle
        and_the_degree_type_is_undergraduate
        and_i_choose_qts
        and_the_degree_type_is_postgraduate
        and_the_back_link_points_to_the_outcome_page
        and_i_choose_the_fee_paying
        and_the_back_link_points_to_the_funding_type_page
        and_i_choose_part_time
        and_the_back_link_points_to_the_study_mode_page

        and_i_click_back
        then_i_am_on_the_study_mode_page

        and_i_click_back
        then_i_am_on_the_funding_type_page

        when_i_update
        and_i_update

        and_i_choose_to_sponsor_a_student_visa
        then_i_see_the_correct_attributes_in_the_database_for_fee_paying
      end
    end

    context 'salaried course' do
      scenario 'changing the outcome from TDA to non TDA' do
        given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
        and_the_tda_feature_flag_is_active
        and_the_db_backed_funding_type_feature_flag_is_disabled
        and_there_is_a_tda_course_i_want_to_edit
        when_i_visit_the_course_outcome_page_in_the_next_cycle
        and_the_degree_type_is_undergraduate
        and_i_choose_qts
        and_the_degree_type_is_postgraduate
        and_the_back_link_points_to_the_outcome_page
        and_i_choose_salaried
        and_the_back_link_points_to_the_funding_type_page
        and_i_choose_part_time
        and_the_back_link_points_to_the_study_mode_page
        and_i_choose_to_sponsor_a_skilled_worker_visa
        then_i_see_the_correct_attributes_in_the_database_for_salaried
      end
    end
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    next_cycle_providers = [build(:provider, :next_recruitment_cycle, :accredited_provider,
                                  courses: [create(:course, :with_accrediting_provider)],
                                  sites: [build(:site), build(:site)],
                                  study_sites: [build(:site, :study_site)])]
    @next_cycle_user = create(:user, providers: next_cycle_providers)
    given_i_am_authenticated(user: @next_cycle_user)
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_qts_course_i_want_to_edit
    given_a_course_exists(:resulting_in_qts)
  end

  def and_there_is_a_tda_course_i_want_to_edit
    given_a_course_exists(:undergraduate_degree_with_qts, degree_type: 'undergraduate')
  end

  def course_enrichment
    @course_enrichment ||= build(:course_enrichment, :draft, course_length: :FourYears, salary_details: 'foobar')
  end

  def and_there_is_a_non_qts_course_i_want_to_edit
    given_a_course_exists(:resulting_in_pgde, level: 'further_education')
  end

  def when_i_visit_the_course_outcome_page
    publish_courses_outcome_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def and_i_update_the_course_outcome
    publish_courses_outcome_edit_page.pgce_with_qts.choose
  end

  def and_i_update_the_course_outcome_to_tda
    publish_courses_outcome_edit_page.pgce_with_qts.choose
  end

  def and_i_submit
    publish_courses_outcome_edit_page.submit.click
  end

  def and_i_update
    click_on 'Update'
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t('success.saved', value: 'Qualification'))
  end

  def and_the_course_outcome_is_updated
    expect(course.reload).to be_pgce_with_qts
  end

  def then_i_am_shown_the_correct_qts_options
    expect(publish_courses_outcome_edit_page.qualification_names).to contain_exactly('QTS', 'QTS with PGCE', 'PGDE with QTS')
  end

  def then_i_am_shown_the_correct_non_qts_options
    expect(publish_courses_outcome_edit_page.qualification_names).to contain_exactly('PGCE only (without QTS)', 'PGDE only (without QTS)')
  end

  def and_i_choose_undergraduate_degree_with_qts
    publish_courses_outcome_edit_page.undergraduate_degree_with_qts.choose
  end

  def and_i_choose_qts
    publish_courses_outcome_edit_page.qts.choose
    and_i_submit
  end

  def and_i_choose_the_fee_paying
    choose 'Fee - no salary'
    and_i_update
  end

  def and_i_choose_to_sponsor_a_student_visa
    choose 'Yes'
    and_i_update
  end

  def and_i_choose_part_time
    uncheck 'Full time'
    check 'Part time'
    and_i_update
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def provider
    @current_user.providers.first
  end

  def given_i_am_authenticated_as_a_provider_user_in_the_next_cycle
    next_cycle_providers = [build(:provider, :accredited_provider, :next_recruitment_cycle,
                                  courses: [create(:course, :with_accrediting_provider, study_mode: 'part_time', funding: 'fee', can_sponsor_skilled_worker_visa: true)])]
    @next_cycle_user = create(:user, providers: next_cycle_providers)
    given_i_am_authenticated(user: @next_cycle_user)
  end

  def next_cycle_provider
    @provider ||= @current_user.providers.first
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def and_there_is_a_qts_course_i_want_to_edit
    given_a_course_exists(:resulting_in_qts, study_mode: 'part_time', funding_type: 'fee', can_sponsor_skilled_worker_visa: true)
  end

  def when_i_visit_the_course_outcome_page_in_the_next_cycle
    publish_courses_outcome_edit_page.load(
      provider_code: next_cycle_provider.provider_code, recruitment_cycle_year: next_cycle_provider.recruitment_cycle_year, course_code: next_cycle_provider.courses.first.course_code
    )
  end

  def and_the_degree_type_is_undergraduate
    expect(course.undergraduate_degree_type?).to be(true)
  end

  def and_the_degree_type_is_postgraduate
    expect(course.reload.postgraduate_degree_type?).to be(true)
  end

  def then_the_default_options_for_a_tda_course_should_be_applied
    course.reload
    expect(course.undergraduate_degree_type?).to be(true)
    expect(course.full_time?).to be(true)
    expect(course.funding_type == 'apprenticeship').to be(true)
    expect(course.can_sponsor_skilled_worker_visa).to be false
    expect(course.can_sponsor_student_visa).to be false
  end

  def then_i_see_the_correct_attributes_in_the_database_for_fee_paying
    course.reload
    expect(course.part_time?).to be(true)
    expect(course.funding_type == 'fee').to be(true)
    expect(course.can_sponsor_skilled_worker_visa).to be(false)
    expect(course.can_sponsor_student_visa).to be(true)
  end

  def and_i_choose_salaried
    choose 'Salary'
    and_i_update
  end

  def then_i_see_the_correct_attributes_in_the_database_for_salaried
    course.reload
    expect(course.study_mode == 'part_time').to be(true)
    expect(course.funding_type == 'salary').to be(true)
    expect(course.can_sponsor_skilled_worker_visa).to be(true)
    expect(course.can_sponsor_student_visa).to be(false)

    expect(course.enrichments.find_or_initialize_draft.course_length).to be_nil
    expect(course.enrichments.find_or_initialize_draft.salary_details).to be_nil
  end

  def and_i_should_be_on_the_course_details_page
    expect(page).to have_current_path(details_publish_provider_recruitment_cycle_course_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, code: course.course_code), ignore_query: true)
  end

  def and_the_back_link_points_to_the_outcome_page
    expect(URI.parse(find_link('Back')[:href]).path).to eq(outcome_publish_provider_recruitment_cycle_course_path(
                                                             provider_code: provider.provider_code,
                                                             recruitment_cycle_year: 2025,
                                                             code: course.course_code
                                                           ))
  end

  def and_the_back_link_points_to_the_funding_type_page
    expect(URI.parse(find_link('Back')[:href]).path).to eq(funding_type_publish_provider_recruitment_cycle_course_path(
                                                             provider_code: provider.provider_code,
                                                             recruitment_cycle_year: 2025,
                                                             code: course.course_code
                                                           ))
  end

  def and_the_back_link_points_to_the_study_mode_page
    expect(URI.parse(find_link('Back')[:href]).path).to eq(full_part_time_publish_provider_recruitment_cycle_course_path(
                                                             provider_code: provider.provider_code,
                                                             recruitment_cycle_year: 2025,
                                                             code: course.course_code
                                                           ))
  end

  def and_i_click_back
    click_on 'Back'
  end

  def then_i_am_on_the_study_mode_page
    expect(page).to have_current_path(full_part_time_publish_provider_recruitment_cycle_course_path(
                                        provider_code: provider.provider_code,
                                        recruitment_cycle_year: 2025,
                                        code: course.course_code,
                                        previous_tda_course: true
                                      ))
  end

  def then_i_am_on_the_funding_type_page
    expect(page).to have_current_path(funding_type_publish_provider_recruitment_cycle_course_path(
                                        provider_code: provider.provider_code,
                                        recruitment_cycle_year: 2025,
                                        code: course.course_code,
                                        previous_tda_course: true
                                      ))
  end

  def and_the_db_backed_funding_type_feature_flag_is_enabled
    allow(Settings.features).to receive(:db_backed_funding_type).and_return(true)
  end

  def and_the_db_backed_funding_type_feature_flag_is_disabled
    allow(Settings.features).to receive(:db_backed_funding_type).and_return(false)
  end

  alias_method :and_i_choose_to_sponsor_a_skilled_worker_visa, :and_i_choose_to_sponsor_a_student_visa
  alias_method :when_i_update, :and_i_update
end
