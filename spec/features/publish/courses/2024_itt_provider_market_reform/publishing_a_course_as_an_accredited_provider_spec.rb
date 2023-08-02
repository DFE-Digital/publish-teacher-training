# frozen_string_literal: true

require 'rails_helper'

feature 'Publishing a course when course when accrediting_provider is nil', { can_edit_current_and_next_cycles: false } do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'Can publish the course if an accredited provider' do
    and_the_provider_is_accredited
    and_there_is_a_draft_course_without_accrediting_provider

    when_i_visit_the_course_page
    and_i_click_the_publish_button
    then_i_should_see_a_success_message
  end

  def given_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def and_there_is_a_draft_course_without_accrediting_provider
    given_a_course_exists(
      :with_gcse_equivalency,
      enrichments: [create(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: 'location 1')],
      study_sites: [create(:site, :study_site)]
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code
    )
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content('Your course has been published.')
  end

  def and_i_click_the_publish_button
    publish_provider_courses_show_page.publish_button.click
  end

  def and_the_provider_is_accredited
    provider.update(accrediting_provider: 'accredited_provider')
  end

  def provider
    @current_user.providers.first
  end
end
