# frozen_string_literal: true

require "rails_helper"

feature "Sending DFE Analytics events" do
  before do
    allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
  end

  scenario "publishing a course" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_course_i_want_to_publish
    when_i_visit_the_course_page
    and_i_click_the_publish_link
    then_it_has_sent_analytics_events
  end

private

  def provider
    @provider ||= @current_user.providers.first
  end

  def publish_provider_courses_show_page
    @publish_provider_courses_show_page ||= PageObjects::Publish::ProviderCoursesShow.new
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider))
  end

  def and_there_is_a_course_i_want_to_publish
    given_a_course_exists(
      :with_gcse_equivalency,
      enrichments: [build(:course_enrichment, :initial_draft)],
      sites: [create(:site, location_name: "location 1")],
    )
  end

  def when_i_visit_the_course_page
    publish_provider_courses_show_page.load(
      provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year, course_code: course.course_code,
    )
  end

  def and_i_click_the_publish_link
    publish_provider_courses_show_page.status_sidebar.publish_button.click
  end

  def then_it_has_sent_analytics_events
    expect(%i[web_request create_entity]).to have_been_enqueued_as_analytics_events
  end
end
