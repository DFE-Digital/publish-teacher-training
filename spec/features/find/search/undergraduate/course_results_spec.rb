# frozen_string_literal: true

require 'rails_helper'

feature 'Questions and results for undergraduate courses' do
  scenario 'when 2025 cycle and undergraduate feature is active' do
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
  end

  def given_i_have_2025_courses
    recruitment_cycle,provider = setup_recruitment_cycle(year: 2025)

    create(:course, :with_teacher_degree_apprenticeship, provider:, name: 'Biology')
    create(:course, :resulting_in_pgce_with_qts, provider:, name: 'Chemistry')
    create(:course, :with_teacher_degree_apprenticeship, provider:, name: 'History')
    create(:course, :resulting_in_pgce_with_qts, provider:, name: 'Mathematics')
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
    recruitment_cycle,provider = setup_recruitment_cycle(year: 2024)

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
end
