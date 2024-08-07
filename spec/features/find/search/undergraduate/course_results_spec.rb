# frozen_string_literal: true

require 'rails_helper'

feature 'Questions and results for undergraduate courses' do
  scenario 'when 2025 cycle and undergraduate feature is active and searching secondary courses' do
    given_i_have_2025_courses
    and_i_am_in_the_2025_cycle
    and_the_tda_feature_flag_is_active
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    then_i_am_on_the_undergraduate_question_page

    and_i_click_continue
    then_i_see_an_error_message_to_the_undergraduate_question_page
    and_the_back_link_points_to_the_secondary_subjects_page

    when_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_yes
    and_i_click_to_find_courses
    then_i_am_on_an_exit_page_for_no_degree_and_need_of_visa_sponsorship

    when_i_click_back
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_no
    and_i_click_to_find_courses

    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
    and_i_can_see_only_secondary_undergraduate_courses
  end

  scenario 'when 2025 cycle and undergraduate feature is active and searching primary courses' do
    given_i_have_2025_courses
    and_i_am_in_the_2025_cycle
    and_the_tda_feature_flag_is_active
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_primary
    and_i_click_continue
    and_i_choose_primary_subjects
    and_i_click_continue
    then_i_am_on_the_undergraduate_question_page
    and_the_back_link_points_to_the_primary_subjects_page

    when_i_choose_no_i_do_not_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page

    when_i_choose_no
    and_i_click_to_find_courses
    then_i_am_on_results_page
    and_some_filters_are_hidden_for_undergraduate_courses
    and_some_filters_are_visible_for_undergraduate_courses
    and_i_can_see_only_primary_undergraduate_courses
  end

  scenario 'when 2024 cycle and undergraduate feature is active' do
    given_i_have_2024_courses
    and_i_am_in_the_2024_cycle
    and_the_tda_feature_flag_is_active
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    then_i_am_on_the_visa_status_page
  end

  scenario 'when 2025 cycle and undergraduate feature is active but search for further education courses' do
    given_i_have_2025_courses
    and_i_am_in_the_2025_cycle
    and_the_tda_feature_flag_is_active

    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_further_education
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    when_i_choose_yes
    and_i_click_to_find_courses
    then_i_am_on_results_page
  end

  scenario 'when 2025 cycle and undergraduate feature is active and searching postgraduate courses' do
    given_i_have_2025_courses
    and_i_am_in_the_2025_cycle
    and_the_tda_feature_flag_is_active
    when_i_visit_the_start_page
    and_i_select_the_across_england_radio_button
    and_i_click_continue
    and_i_choose_secondary
    and_i_click_continue
    and_i_choose_subjects
    and_i_click_continue
    then_i_am_on_the_undergraduate_question_page

    when_i_choose_yes_i_have_a_degree
    and_i_click_continue
    then_i_am_on_the_visa_status_page
    and_the_back_link_points_to_the_degree_question

    when_i_choose_no
    and_i_click_to_find_courses
    then_i_am_on_results_page
    and_all_filters_are_visible
    and_i_can_see_only_postgraduate_courses
  end

  def given_i_have_2025_courses
    _, provider = setup_recruitment_cycle(year: 2025)

    @biology_course = create(:course, :open, :published, :with_full_time_sites, :with_teacher_degree_apprenticeship, :resulting_in_undergraduate_degree_with_qts, :secondary, provider:, name: 'Biology', subjects: [find_or_create(:secondary_subject, :biology)])
    @chemistry_course = create(:course, :open, :published, :with_full_time_sites, :resulting_in_pgce_with_qts, :secondary, provider:, name: 'Chemistry', subjects: [find_or_create(:secondary_subject, :chemistry)])
    @history_course = create(:course, :open, :published, :with_full_time_sites, :with_teacher_degree_apprenticeship, :resulting_in_undergraduate_degree_with_qts, :secondary, provider:, name: 'History', subjects: [find_or_create(:secondary_subject, :history)])
    @mathematics_course = create(:course, :open, :published, :with_full_time_sites, :resulting_in_pgce_with_qts, :secondary, provider:, name: 'Mathematics', subjects: [find_or_create(:secondary_subject, :mathematics)])
    @primary_with_science_course = create(:course, :open, :published, :with_full_time_sites, :with_teacher_degree_apprenticeship, :resulting_in_undergraduate_degree_with_qts, :primary, provider:, name: 'Primary with science', subjects: [find_or_create(:primary_subject, :primary_with_science)])
  end

  def setup_recruitment_cycle(year:)
    recruitment_cycle = create(:recruitment_cycle, year:)
    user = create(:user, providers: [build(:provider, recruitment_cycle:, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    provider = user.providers.first
    create(:provider, :accredited_provider, provider_code: '1BJ')
    accredited_provider = create(:provider, :accredited_provider, provider_code: '1BJ', recruitment_cycle:)
    provider.accrediting_provider_enrichments = []
    provider.accrediting_provider_enrichments << AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: accredited_provider.provider_code,
        Description: 'description'
      }
    )
    [recruitment_cycle, provider]
  end

  def given_i_have_2024_courses
    _, provider = setup_recruitment_cycle(year: 2024)

    create(:course, :resulting_in_pgce_with_qts, provider:, name: 'Chemistry')
    create(:course, :resulting_in_pgce_with_qts, provider:, name: 'Mathematics')
  end

  def and_i_am_in_the_2025_cycle
    Timecop.travel(Time.zone.local(2024, 10, 1, 9, 1)) # after Find opens
    allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025)
  end

  def and_i_am_in_the_2024_cycle
    Timecop.travel(Time.zone.local(2024, 8, 1, 9))
    allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def when_i_visit_the_start_page
    find_courses_by_location_or_training_provider_page.load
  end

  def and_i_select_the_across_england_radio_button
    find_courses_by_location_or_training_provider_page.across_england.choose
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def and_i_choose_secondary
    choose 'Secondary'
  end

  def and_i_choose_primary
    choose 'Primary'
  end

  def and_i_choose_primary_subjects
    check 'Primary with science'
  end

  def and_i_choose_subjects
    check 'Biology'
    check 'Chemistry'
    check 'History'
    check 'Mathematics'
  end

  def then_i_am_on_the_undergraduate_question_page
    expect(page).to have_current_path(
      find_university_degree_status_path,
      ignore_query: true
    )

    expect(page).to have_content('Do you have a university degree?')
  end

  def then_i_am_on_the_visa_status_page
    expect(page).to have_current_path(
      find_visa_status_path,
      ignore_query: true
    )
  end

  def and_i_choose_further_education
    choose 'Further education'
  end

  def then_i_see_an_error_message_to_the_undergraduate_question_page
    expect(page).to have_content(
      'Select whether you have a university degree'
    )
  end

  def when_i_choose_no
    choose 'No'
  end

  def when_i_choose_no_i_do_not_have_a_degree
    choose 'No, I do not have a degree'
  end

  def when_i_choose_yes_i_have_a_degree
    choose 'Yes, I have a degree or am studying for one'
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def then_i_am_on_an_exit_page_for_no_degree_and_need_of_visa_sponsorship
    expect(page).to have_current_path(
      find_no_degree_and_requires_visa_sponsorship_path,
      ignore_query: true
    )

    expect(page).to have_content('You are not eligible for teacher training courses on this service.')
  end

  def then_i_am_on_results_page
    expect(page).to have_current_path(
      find_results_path,
      ignore_query: true
    )
  end

  def and_i_click_to_find_courses
    click_link_or_button 'Find courses'
  end

  def and_some_filters_are_hidden_for_undergraduate_courses
    within 'form.app-filter' do
      expect(page).to have_no_content('Study type')
      expect(page).to have_no_content('Qualifications')
      expect(page).to have_no_content('Degree grade accepted')
      expect(page).to have_no_content('Salary')
      expect(page).to have_no_content('Qualifications')
    end
  end

  def and_some_filters_are_visible_for_undergraduate_courses
    within 'form.app-filter' do
      expect(page).to have_content('Special educational needs')
      expect(page).to have_content('Applications open')
    end
  end

  def and_i_can_see_only_primary_undergraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Primary with science')
      expect(page).to have_content(@primary_with_science_course.course_code)
      expect(page).to have_no_content('Biology')
      expect(page).to have_no_content(@biology_course.course_code)
      expect(page).to have_no_content('History')
      expect(page).to have_no_content(@history_course.course_code)
      expect(page).to have_no_content('Chemistry')
      expect(page).to have_no_content(@chemistry_course.course_code)
      expect(page).to have_no_content('Mathematics')
      expect(page).to have_no_content(@mathematics_course.course_code)
    end
  end

  def and_i_can_see_only_secondary_undergraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Biology')
      expect(page).to have_content(@biology_course.course_code)
      expect(page).to have_content('History')
      expect(page).to have_content(@history_course.course_code)
      expect(page).to have_no_content('Primary with science')
      expect(page).to have_no_content(@primary_with_science_course.course_code)
      expect(page).to have_no_content('Chemistry')
      expect(page).to have_no_content(@chemistry_course.course_code)
      expect(page).to have_no_content('Mathematics')
      expect(page).to have_no_content(@mathematics_course.course_code)
    end
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def and_the_back_link_points_to_the_degree_question
    expect(back_link[:href]).to include(find_university_degree_status_path)
  end

  def and_the_back_link_points_to_the_secondary_subjects_page
    expect(back_link[:href]).to include(find_subjects_path(age_group: 'secondary'))
  end

  def and_the_back_link_points_to_the_primary_subjects_page
    expect(back_link[:href]).to include(find_subjects_path(age_group: 'primary'))
  end

  def and_all_filters_are_visible
    within 'form.app-filter' do
      expect(page).to have_content('Study type')
      expect(page).to have_content('Qualifications')
      expect(page).to have_content('Degree grade accepted')
      expect(page).to have_content('Salary')
      expect(page).to have_content('Qualifications')
      expect(page).to have_content('Special educational needs')
      expect(page).to have_content('Applications open')
    end
  end

  def and_i_can_see_only_postgraduate_courses
    within '.app-search-results' do
      expect(page).to have_content('Chemistry')
      expect(page).to have_content(@chemistry_course.course_code)
      expect(page).to have_content('Mathematics')
      expect(page).to have_content(@mathematics_course.course_code)
      expect(page).to have_no_content('Biology')
      expect(page).to have_no_content(@biology_course.course_code)
      expect(page).to have_no_content('History')
      expect(page).to have_no_content(@history_course.course_code)
      expect(page).to have_no_content('Primary with science')
      expect(page).to have_no_content(@primary_with_science_course.course_code)
    end
  end

  def back_link
    page.find_link('Back')
  end
end
