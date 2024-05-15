# frozen_string_literal: true

require 'rails_helper'

feature 'Adding a teacher degree apprenticeship course', :can_edit_current_and_next_cycles do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_the_tda_feature_flag_is_active
  end

  scenario 'creating a degree awarding course' do
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
    # We skip the visa sponsorship question
    then_i_am_on_the_add_applications_open_date_page

    when_i_choose_the_applications_open_date
    and_i_choose_the_course_start_date
    then_i_am_on_the_check_your_answers_page

    when_i_click_on_add_a_course
    then_the_tda_course_is_created
    and_the_tda_defaults_are_saved
  end

  # scenario 'changing from tda to non tda on check your answers page' do
  # end

  # scenario 'changing from non tda to tda on check your answers page' do
  # end

  # scenario 'when choosing a further education course' do
  # end

  # scenario 'when choosing primary course' do
  # end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(
      :user,
      providers: [
        create(:provider, :accredited_provider, recruitment_cycle: build(:recruitment_cycle, year: 2025), sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])
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
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/2025/courses/funding-type/new?course%5Bage_range_in_years%5D=14_to_19&course%5Bcampaign_name%5D=&course%5Bis_send%5D=0&course%5Blevel%5D=secondary&course%5Bmaster_subject_id%5D=17&course%5Bqualification%5D=undergraduate_degree_with_qts&course%5Bsubjects_ids%5D%5B%5D=17")
  end

  def provider
    @user.providers.first
  end
end
