# frozen_string_literal: true

require 'rails_helper'

feature 'Adding A levels to a teacher degree apprenticeship course', :can_edit_current_and_next_cycles do
  scenario 'adding a level requirements' do
    given_i_am_authenticated_as_a_provider_user
    and_the_tda_feature_flag_is_active
    and_i_have_a_teacher_degree_apprenticeship_course

    when_i_visit_the_course_description_tab
    then_i_see_a_levels_row

    when_i_click_to_add_a_level_requirements
    then_i_am_on_the_a_levels_required_for_the_course_page

    when_i_click_continue
    then_i_see_an_error_message_for_the_a_levels_required_for_the_course_page

    when_i_choose_no
    and_i_click_continue
    then_i_am_on_the_course_description_tab
    and_i_see_a_levels_is_no_required

    when_i_click_to_add_a_level_requirements
    then_i_am_on_the_a_levels_required_for_the_course_page

    when_i_choose_yes
    and_i_click_continue
    then_i_am_on_the_what_a_level_is_required_page
  end

  def given_i_am_authenticated_as_a_provider_user
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

    given_i_am_authenticated(user: @user)
  end

  def and_the_tda_feature_flag_is_active
    allow(Settings.features).to receive(:teacher_degree_apprenticeship).and_return(true)
  end

  def and_i_have_a_teacher_degree_apprenticeship_course
    @course = create(:course, :with_teacher_degree_apprenticeship, provider: @provider)
  end

  def when_i_visit_the_course_description_tab
    publish_provider_courses_show_page.load(provider_code: @provider.provider_code, recruitment_cycle_year: 2025, course_code: @course.course_code)
  end

  def then_i_see_a_levels_row
    expect(page).to have_content('A-levels and equivalency tests')
  end

  def when_i_click_to_add_a_level_requirements
    click_on 'Enter A-levels and equivalency test requirements'
  end

  def then_i_am_on_the_a_levels_required_for_the_course_page
    expect(page).to have_current_path('change-me')
  end

  def when_i_click_continue
    click_on 'Continue'
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_see_an_error_message_for_the_a_levels_required_for_the_course_page; end

  def when_i_choose_no
    choose 'No'
  end

  def then_i_am_on_the_course_description_tab; end

  def and_i_see_a_levels_is_no_required; end

  def when_i_choose_yes
    choose 'Yes'
  end

  def then_i_am_on_the_what_a_level_is_required_page; end
end
