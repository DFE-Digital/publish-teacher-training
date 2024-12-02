# frozen_string_literal: true

require 'rails_helper'

feature 'Course show', { can_edit_current_and_next_cycles: false } do
  scenario 'when viewing a teacher degree apprenticeship course' do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_a_teacher_degree_apprenticeship_course

    when_i_visit_the_course_page
    then_i_should_see_the_link_to_preview

    when_i_click_to_preview_the_course
    then_i_see_the_a_level_requirements_content
    and_i_do_not_see_the_degree_content
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, providers: [build(:provider, provider_type: 'lead_partner', sites: [build(:site), build(:site)], study_sites: [build(:site, :study_site), build(:site, :study_site)])])
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

  def and_i_have_a_teacher_degree_apprenticeship_course
    @course = create(
      :course,
      :with_teacher_degree_apprenticeship,
      :with_a_level_requirements,
      :resulting_in_undergraduate_degree_with_qts,
      provider: @provider,
      additional_a_level_equivalencies: 'Some additional text about A level equivalencies',
      a_level_subject_requirements: [
        { 'uuid' => 'uuid-1', 'subject' => 'any_subject', 'minimum_grade_required' => 'A' },
        { 'uuid' => 'uuid-1', 'subject' => 'any_modern_foreign_language', 'minimum_grade_required' => 'A*' },
        { 'uuid' => 'uuid-2', 'subject' => 'any_modern_foreign_language', 'minimum_grade_required' => 'A*' }
      ],
      degree_grade: nil,
      additional_degree_subject_requirements: nil,
      degree_subject_requirements: nil
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
    expect(page).to have_content('Any subject - Grade A or above or equivalent qualification')
    expect(page).to have_content('Any two modern foreign languages - Grade A* or equivalent qualification')
    expect(page).to have_content('We’ll consider candidates with pending A levels.')
    expect(page).to have_content('We’ll consider candidates who need to take A level equivalency tests.')
    expect(page).to have_content('Some additional text about A level equivalencies')
  end

  def and_i_do_not_see_the_degree_content
    expect(page).to have_no_content('An undergraduate degree, or equivalent')
    expect(page).to have_no_content('Enter degree requirements')
  end
end
