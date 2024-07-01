# frozen_string_literal: true

require 'rails_helper'

feature 'Course show', { can_edit_current_and_next_cycles: false } do
  scenario 'when viewing a teacher degree apprenticeship course' do
    given_i_am_authenticated_as_a_provider_user
    and_the_tda_feature_flag_is_active
    and_i_have_a_teacher_degree_apprenticeship_course

    when_i_visit_the_course_page
    then_i_should_see_the_link_to_preview

    when_i_click_to_preview_the_course
    then_i_see_the_a_level_requirements_content
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
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      :with_a_level_requirements,
      :resulting_in_undergraduate_degree_with_qts,
      provider: @provider,
      additional_a_level_equivalencies: 'Some additional text about A level equivalencies'
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: @provider.provider_code,
      recruitment_cycle_year: @provider.recruitment_cycle_year,
      course_code: @course.course_code
    )
  end

  def then_i_should_see_the_link_to_preview
    expect(page).to have_content('Preview course')
  end

  def when_i_click_to_preview_the_course
    click_on 'Preview course'
  end

  def then_i_see_the_a_level_requirements_content
    expect(page).to have_content('A levels')
    expect(page).to have_content('Any subject - Grade A or above, or equivalent qualification')
    expect(page).to have_content('We’ll consider candidates with pending A levels.')
    expect(page).to have_content('We’ll consider candidates who need to take A level equivalency tests.')
    expect(page).to have_content('Some additional text about A level equivalencies')
  end
end
