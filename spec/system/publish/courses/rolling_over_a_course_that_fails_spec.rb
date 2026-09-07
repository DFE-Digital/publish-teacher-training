# frozen_string_literal: true

require "rails_helper"

# Providers::CopyToRecruitmentCycleService collects per-course failures into
# `courses_failed` and lets the surrounding transaction commit, so a failed
# rollover can still copy the provider and its sites. The page must not report
# success when the course itself did not make it into the next cycle.
#
# A course row with no start date makes the copy fail for real:
# Courses::CopyToProviderService adds a year to `start_date` before it saves the
# new course, so the failure lands before any course row is written.
RSpec.describe "Rolling over a course that fails to copy", travel: mid_cycle(2025) do
  scenario "the provider is told the course was not rolled over" do
    given_i_am_authenticated_as_a_provider_user
    and_there_is_a_rollable_next_recruitment_cycle
    and_the_course_has_no_start_date
    when_i_visit_the_rollover_page
    and_i_confirm_the_rollover
    then_i_see_that_the_course_was_not_rolled_over
    and_i_am_not_told_it_was_rolled_over
    and_the_course_is_not_in_the_next_recruitment_cycle
  end

  def given_i_am_authenticated_as_a_provider_user
    @course = build(:course, enrichments: [build(:course_enrichment)], funding_type: "salary")
    @provider = create(:provider, courses: [@course])
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
  end

  def and_there_is_a_rollable_next_recruitment_cycle
    find_or_create(:recruitment_cycle, :next).update(available_in_publish_from: 1.hour.ago)
  end

  def and_the_course_has_no_start_date
    @course.update_columns(start_date: nil)
  end

  def when_i_visit_the_rollover_page
    visit rollover_publish_provider_recruitment_cycle_course_path(
      @provider.provider_code,
      @provider.recruitment_cycle_year,
      @course.course_code,
    )
  end

  def and_i_confirm_the_rollover
    click_link_or_button "Roll over course"
  end

  def then_i_see_that_the_course_was_not_rolled_over
    expect(page).to have_content "This course could not be rolled over. Try again, or contact becomingateacher@digital.education.gov.uk for help."
  end

  def and_i_am_not_told_it_was_rolled_over
    expect(page).to have_no_content "Course rolled over"
  end

  def and_the_course_is_not_in_the_next_recruitment_cycle
    next_cycle_provider = RecruitmentCycle.next.providers.find_by(provider_code: @provider.provider_code)

    expect(next_cycle_provider).to be_present
    expect(next_cycle_provider.courses).to be_empty
  end
end
