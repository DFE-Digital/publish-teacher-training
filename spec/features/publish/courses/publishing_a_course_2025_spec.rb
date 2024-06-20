# frozen_string_literal: true

# Regression test can be deleted in the next recruitment cycle

require 'rails_helper'

feature 'Publishing courses', can_edit_current_and_next_cycles: false do
  scenario 'i can publish a course in 2025' do
    given_the_current_recruitment_cycle_is2025
    and_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
  end

  def and_i_am_authenticated_as_a_provider_user
    @user = create(:user, :with_provider)
    given_i_am_authenticated(user: @user)
  end

  def given_the_current_recruitment_cycle_is2025
    allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025)
  end

  def and_there_is_a_course_i_want_to_publish
    given_a_course_exists(
      :with_gcse_equivalency,
      :with_accrediting_provider,
      enrichments: [create(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: 'location 1')],
      study_sites: [create(:site, :study_site)]
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def and_i_click_the_publish_link
    publish_provider_courses_show_page.course_button_panel.publish_button.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content('Your course has been published.')
  end

  def and_the_course_is_published
    expect(course.reload.is_published?).to be(true)
  end

  def provider
    @current_user.providers.first
  end
end
