# frozen_string_literal: true

require "rails_helper"

feature "Publishing courses" do
  before do
    given_the_can_edit_current_and_next_cycles_feature_flag_is_disabled
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "i can publish a course" do
    and_there_is_a_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
  end

  scenario "i can re-publish a course" do
    and_i_have_previously_published_a_course
    when_i_make_some_new_changes
    then_i_should_see_the_unpublished_changes_message
    and_i_should_see_the_publish_button
  end

  scenario "attempting to publish with errors" do
    and_there_is_a_draft_course
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_an_error_message_for_the_gcses
    when_i_click_the_error_message_link
    then_it_takes_me_to_the_gcses_page
    and_the_relevant_errors_are_shown
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_i_have_previously_published_a_course
    and_there_is_a_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_i_should_see_a_success_message
    and_the_course_is_published
  end

  def and_there_is_a_course_i_want_to_publish
    given_a_course_exists(
      :with_gcse_equivalency,
      enrichments: [build(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: "location 1")],
    )
  end

  def and_there_is_a_draft_course
    given_a_course_exists(
      enrichments: [build(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: "location 1")],
    )
  end

  def and_there_is_a_published_course
    given_a_course_exists(enrichments: [build(:course_enrichment, :published)])
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_click_the_publish_link
    publish_provider_courses_show_page.status_sidebar.publish_button.click
  end

  def then_i_should_see_a_success_message
    expect(page).to have_content("Your course has been published.")
  end

  def and_the_course_is_published
    expect(course.reload.is_published?).to be(true)
  end

  def when_i_make_some_new_changes
    publish_course_information_page.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code)
    publish_course_information_page.about_course.set("some new description")
    publish_course_information_page.submit.click
  end

  def then_i_should_see_the_unpublished_changes_message
    expect(page).to have_content("* Unpublished changes")
  end

  def and_i_should_see_the_publish_button
    expect(publish_provider_courses_show_page.status_sidebar.publish_button).to be_visible
  end

  def then_i_should_see_an_error_message_for_the_gcses
    expect(publish_provider_courses_show_page.error_messages).to include("Enter GCSE requirements")
  end

  def when_i_click_the_error_message_link
    publish_provider_courses_show_page.errors.first.link.click
  end

  def then_it_takes_me_to_the_gcses_page
    expect(gcse_requirements_page).to be_displayed
  end

  def and_the_relevant_errors_are_shown
    expect(gcse_requirements_page.error_messages).to be_present
  end

  def provider
    @current_user.providers.first
  end
end
