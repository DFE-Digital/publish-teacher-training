# frozen_string_literal: true

require "rails_helper"

# Publishing a course in a future cycle shows it as Scheduled. Closing it
# shows Closed.
RSpec.describe "Closing a scheduled course", travel: mid_cycle do
  scenario "a closed scheduled course shows as closed" do
    given_i_am_authenticated_as_a_provider_user
    and_i_have_published_a_course_in_the_next_cycle
    when_i_visit_the_course_page
    then_the_course_shows_as_scheduled
    when_i_close_the_course
    then_the_course_is_closed
    and_the_tag_shows_as_closed
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(user: create(:user, :with_provider, provider: next_cycle_provider))
  end

  def next_cycle_provider
    @next_cycle_provider ||= create(:provider, :next_recruitment_cycle)
  end

  def and_i_have_published_a_course_in_the_next_cycle
    @course = create(:course, :published, provider: next_cycle_provider, application_status: :open)
  end

  def when_i_visit_the_course_page
    visit publish_provider_recruitment_cycle_course_path(
      course.provider.provider_code,
      course.recruitment_cycle.year,
      course.course_code,
    )
  end

  def then_the_course_shows_as_scheduled
    expect(status_tag).to have_text("Scheduled")
  end

  def when_i_close_the_course
    click_link_or_button "Close course"
    click_link_or_button "Close course"
  end

  def then_the_course_is_closed
    expect(course.reload).to be_application_status_closed
    expect(page).to have_text("Course closed")
  end

  def and_the_tag_shows_as_closed
    expect(status_tag).to have_text("Closed")
    expect(status_tag).to have_no_text("Scheduled")
  end

  def status_tag
    page.find("h1 .govuk-tag")
  end

  def course
    @course
  end
end
