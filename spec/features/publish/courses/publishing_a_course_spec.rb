# frozen_string_literal: true

require 'rails_helper'

feature 'Publishing courses', { can_edit_current_and_next_cycles: false } do
  before do
    Timecop.travel(Find::CycleTimetable.mid_cycle)
    given_i_am_authenticated_as_a_provider_user
  end

  scenario 'i can publish a course' do
    and_there_is_a_draft_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
    and_the_course_is_open
  end

  scenario 'i can publish a rolled over course' do
    and_there_is_a_rolled_over_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
    and_the_course_is_open
  end

  scenario 'i can re-publish a course' do
    and_i_have_previously_published_a_course
    when_i_make_some_new_changes
    then_i_should_see_the_unpublished_changes_message
    and_i_do_not_see_the_unpublished_content_on_find
    when_i_return_to_publish
    and_i_should_see_the_publish_button
    and_i_click_the_publish_link
    then_i_see_the_content_on_find
  end

  scenario 'attempting to publish with errors' do
    and_there_is_a_draft_course
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_an_error_message_for_the_gcses
    when_i_click_the_error_message_link
    then_it_takes_me_to_the_gcses_page
    and_the_relevant_errors_are_shown
  end

  def given_i_am_authenticated_as_a_provider_user
    provider = create(:provider, provider_name: 'Cup')
    @user = create(:user, :with_provider, provider:)
    given_i_am_authenticated(user: @user)
  end

  def and_i_am_authed_again
    given_i_am_authenticated(user: @user)
  end

  def and_i_have_previously_published_a_course
    and_there_is_a_draft_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
  end

  def and_there_is_a_draft_course_i_want_to_publish
    given_a_course_exists(
      :with_gcse_equivalency,
      :with_accrediting_provider,
      :closed,
      accrediting_provider:,
      enrichments: [build(:course_enrichment, :initial_draft)],
      sites: [build(:site, location_name: 'location 1')],
      study_sites: [build(:site, :study_site)]
    )
  end

  def and_there_is_a_rolled_over_course_i_want_to_publish
    given_a_course_exists(
      :with_gcse_equivalency,
      :with_accrediting_provider,
      :closed,
      accrediting_provider:,
      enrichments: [create(:course_enrichment, :rolled_over)],
      sites: [create(:site, location_name: 'location 1')],
      study_sites: [create(:site, :study_site)]
    )
  end

  def and_there_is_a_draft_course
    given_a_course_exists(
      :with_accrediting_provider,
      accrediting_provider:,
      enrichments: [create(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: 'location 1')],
      study_sites: [create(:site, :study_site)]
    )
  end

  def and_there_is_a_published_course
    given_a_course_exists(enrichments: [create(:course_enrichment, :published)])
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

  def and_the_course_is_open
    expect(course.reload).to be_application_status_open
  end

  def when_i_make_some_new_changes
    visit school_placements_publish_provider_recruitment_cycle_course_path(
      provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
    fill_in 'How placements work', with: 'some new information about school placements'
    click_on 'Update how placements work'
  end

  def then_i_should_see_the_unpublished_changes_message
    expect(page).to have_content('* Unpublished changes')
  end

  def and_i_do_not_see_the_unpublished_content_on_find
    page.driver.header 'Host', 'find'
    visit "/course/#{provider.provider_code}/#{course.course_code}"
    expect(page).to have_no_content('some new information about school placements')
  end

  def then_i_see_the_content_on_find
    page.driver.header 'Host', 'find'
    visit "/course/#{provider.provider_code}/#{course.course_code}"
    expect(page).to have_content('some new information about school placements')
  end

  def when_i_return_to_publish
    page.driver.header 'Host', 'publish'
    and_i_am_authed_again
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code
    )
  end

  def and_i_should_see_the_publish_button
    expect(publish_provider_courses_show_page.course_button_panel.publish_button).to be_visible
  end

  def then_i_should_see_an_error_message_for_the_gcses
    expect(publish_provider_courses_show_page.error_messages).to include('Enter GCSE requirements')
  end

  def when_i_click_the_error_message_link
    publish_provider_courses_show_page.errors.first.link.click
  end

  def then_it_takes_me_to_the_gcses_page
    expect(publish_courses_gcse_requirements_page).to be_displayed
  end

  def and_the_relevant_errors_are_shown
    expect(publish_courses_gcse_requirements_page.error_messages).to be_present
  end

  def accrediting_provider
    build(:accredited_provider)
  end

  def provider
    @current_user.providers.first
  end
end
