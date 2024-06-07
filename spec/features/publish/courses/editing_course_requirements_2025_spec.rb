# frozen_string_literal: true

require 'rails_helper'

feature 'Editing course deprecated requirements in 2025', { can_edit_current_and_next_cycles: false } do
  before do
    allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025)
    enable_features(:course_requirements_deprecated)
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_edit
    provider
  end

  scenario 'there are no links to the course requirements page' do
    when_i_visit_the_course_details_page
    then_there_is_no_link_to_course_requirements
  end

  scenario 'I can not visit the other requirements page' do
    expect do
      visit requirements_publish_provider_recruitment_cycle_course_path(@course.provider.provider_code, 2025, @course.course_code)
    end.to raise_error(ActionController::UrlGenerationError)
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_edit
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def then_there_is_no_link_to_course_requirements
    expect(page).to have_no_content('Other requirements')
  end

  def when_i_visit_the_course_details_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def when_i_visit_the_course_requirements_page
    publish_course_requirement_edit_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content(I18n.t('success.saved', value: 'Personal qualities and other requirements'))
  end

  def provider
    @current_user.providers.first
  end
end
