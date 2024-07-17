# frozen_string_literal: true

require 'rails_helper'

feature 'Publishing courses errors', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_the_tda_feature_flag_is_active
  end

  scenario 'The error links target the correct pages' do
    and_there_is_an_invalid_tda_course_i_want_to_publish

    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_see_a_level_subject_is_required

    when_i_click_on_the_a_level_is_required_error
    then_i_am_on_the_what_a_levels_is_required_for_the_course_page
    and_i_see_what_a_level_required_error

    when_i_choose_any_subject
    and_i_click_continue

    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_see_pending_a_level_is_required

    when_i_click_on_the_pending_a_level_error
    then_i_am_on_the_consider_pending_a_level_page
    and_i_see_the_pending_a_level_error

    when_i_choose_yes
    and_i_click_continue

    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_see_a_level_equivalencies_is_required

    when_i_click_on_the_a_level_equivalencies
    then_i_am_on_the_a_level_equivalencies_page

    when_i_choose_yes
    and_i_click_update_a_levels

    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_the_course_is_published
  end

  scenario 'when the TDA course is published and I try to change qualification' do
    given_there_is_an_published_tda_course
    when_i_visit_the_course_page
    and_i_enter_the_basic_details_tab
    then_there_is_no_change_qualification_link
  end

  scenario 'when the non TDA course is published and I try to change qualification' do
    given_there_is_an_published_qts_course
    when_i_visit_the_course_page
    and_i_enter_the_basic_details_tab
    and_i_click_change_qualification
    then_the_tda_option_is_not_available
    and_i_on_the_change_qualification_page
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: 'lead_school', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
    @provider = @user.providers.first
    create(:provider, :accredited_provider, provider_code: '1BJ')
    @accredited_provider = create(:provider, :accredited_provider, provider_code: '1BK')
    @provider.accrediting_provider_enrichments = []
    @provider.accrediting_provider_enrichments << AccreditingProviderEnrichment.new(
      {
        UcasProviderCode: @accredited_provider.provider_code,
        Description: 'description'
      }
    )

    given_i_am_authenticated(user: @user)
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def and_there_is_an_invalid_tda_course_i_want_to_publish
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      :resulting_in_undergraduate_degree_with_qts,
      :with_gcse_equivalency,
      :draft_enrichment,
      provider: @provider,
      accrediting_provider: @accredited_provider,
      a_level_subject_requirements: [],
      accept_pending_a_level: nil,
      accept_a_level_equivalency: nil
    )
    @course.sites << build_list(:site, 1, provider: @provider)
  end

  def given_there_is_an_published_tda_course
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      :resulting_in_undergraduate_degree_with_qts,
      :with_gcse_equivalency,
      :published,
      provider: @provider,
      accrediting_provider: @accredited_provider,
      a_level_subject_requirements: [],
      accept_pending_a_level: nil,
      accept_a_level_equivalency: nil
    )
    @course.sites << build_list(:site, 1, provider: @provider)
  end

  def given_there_is_an_published_qts_course
    @course = create(
      :course,
      :resulting_in_qts,
      :with_gcse_equivalency,
      :published,
      provider: @provider,
      accrediting_provider: @accredited_provider
    )
    @course.sites << build_list(:site, 1, provider: @provider)
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: @course.course_code
    )
  end

  def then_i_am_on_the_course_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_path(
        @provider.provider_code,
        2025,
        @course.course_code
      )
    )
  end

  def then_there_is_no_change_qualification_link
    expect(publish_provider_courses_details_page.outcome.actions.text).to be_empty
  end

  def and_i_enter_the_basic_details_tab
    click_on 'Basic details'
  end

  def and_i_click_change_qualification
    publish_provider_courses_details_page.outcome.actions.find('a').click
  end

  def then_the_tda_option_is_not_available
    expect(page).to have_no_field('Teacher degree apprenticeship (TDA) with QTS', type: 'radio')
  end

  def and_i_on_the_change_qualification_page
    expect(page).to have_current_path(
      outcome_publish_provider_recruitment_cycle_course_path(
        @course.provider.provider_code,
        @course.provider.recruitment_cycle_year,
        @course.course_code
      )
    )
  end

  def and_i_click_the_publish_link
    publish_provider_courses_show_page.course_button_panel.publish_button.click
  end
  alias_method :when_i_click_the_publish_link, :and_i_click_the_publish_link

  def then_i_see_a_level_subject_is_required
    and_i_see_that_i_need_to_enter_a_level_requirements
    expect(page).to have_content('What A level is required?')
  end

  def and_i_see_that_i_need_to_enter_a_level_requirements
    within '.govuk-error-summary' do
      expect(page).to have_content('Enter A level requirements')
    end
  end

  def and_i_see_a_level_is_required_in_a_level_row
    expect(page).to have_content('Enter A level requirements').twice
  end

  def when_i_click_on_the_a_level_is_required_error
    click_on 'Enter A level requirements', match: :first
  end

  def and_i_see_a_level_required_error
    expect(page).to have_content('Select if this course requires any A levels').twice
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def then_i_am_on_the_what_a_levels_is_required_for_the_course_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_what_a_level_is_required_path(
        @provider.provider_code,
        2025,
        @course.course_code,
        display_errors: true
      )
    )
  end

  def and_i_see_what_a_level_required_error
    expect(page).to have_content('Select a subject').twice
  end

  def when_i_choose_any_subject
    choose 'Any subject'
  end

  def then_i_see_pending_a_level_is_required
    expect(page).to have_content('Enter information on pending A levels').twice
    expect(page).to have_content('Will you consider candidates with pending A levels?')
  end

  def when_i_click_on_the_pending_a_level_error
    click_on 'Enter information on pending A levels', match: :first
  end

  def then_i_am_on_the_consider_pending_a_level_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_consider_pending_a_level_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
        display_errors: true
      )
    )
  end

  def and_i_see_the_pending_a_level_error
    expect(page).to have_content('Select if you will consider candidates with pending A levels').twice
  end

  def then_i_see_a_level_equivalencies_is_required
    expect(page).to have_content('Will you consider candidates who need to take an equivalency test for their A levels?')
    expect(page).to have_content('Enter A level equivalency test requirements').twice
  end

  def when_i_click_on_the_a_level_equivalencies
    click_on 'Enter A level equivalency test requirements', match: :first
  end

  def then_i_am_on_the_a_level_equivalencies_page
    expect(page).to have_current_path(
      publish_provider_recruitment_cycle_course_a_levels_a_level_equivalencies_path(
        @provider.provider_code,
        @provider.recruitment_cycle_year,
        @course.course_code,
        display_errors: true
      )
    )
  end

  def and_i_click_update_a_levels
    click_on 'Update A levels'
  end

  def then_the_course_is_published
    expect(page).to have_content('Your course has been published.')
    expect(@course.reload.is_published?).to be true
  end
end
