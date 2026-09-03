# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Viewing a previous-cycle course on Find", service: :find do
  scenario "a 2026 cycle course is shown before the start date", travel: find_opens(2027) + 1.day do
    given_there_is_a_previous_cycle_course(year: 2026, start_date: Time.zone.local(2026, 10, 1), name: "History")
    and_there_is_a_current_cycle_course_with_the_same_codes

    when_i_visit_the_previous_cycle_course_page

    then_i_see_the_previous_cycle_course
    and_i_see_the_previous_cycle_banner
    and_i_cannot_apply
    and_i_do_not_see_the_current_cycle_course
  end

  scenario "a 2026 cycle course is not shown after the start date", travel: Time.zone.local(2026, 10, 2) do
    given_there_is_a_previous_cycle_course(year: 2026, start_date: Time.zone.local(2026, 10, 1))

    when_i_visit_the_previous_cycle_course_page

    then_i_see_page_not_found
  end

  scenario "a 2026 cycle course that does not start after September is not shown", travel: find_opens(2027) + 1.hour do
    given_there_is_a_previous_cycle_course(year: 2026, start_date: Time.zone.local(2026, 9, 30))

    when_i_visit_the_previous_cycle_course_page

    then_i_see_page_not_found
  end

  scenario "a 2025 cycle course is not shown", travel: find_opens(2026) + 1.day do
    given_there_is_a_previous_cycle_course(year: 2025, start_date: Time.zone.local(2025, 11, 1))

    when_i_visit_the_previous_cycle_course_page

    then_i_see_page_not_found
  end

  scenario "the current-cycle course page is unchanged", travel: find_opens(2027) + 1.day do
    given_there_is_a_current_cycle_course

    when_i_visit_the_current_cycle_course_page

    then_i_see_the_current_cycle_course
    and_i_do_not_see_the_previous_cycle_banner
    and_i_can_apply
  end

  def given_there_is_a_previous_cycle_course(year:, start_date:, name: "History")
    previous_cycle = find_or_create(:recruitment_cycle, year:)
    provider = create(:provider, recruitment_cycle: previous_cycle, provider_code: "ABC")
    @previous_cycle_course = published_course(provider:, name:, start_date:)
  end

  def and_there_is_a_current_cycle_course_with_the_same_codes
    given_there_is_a_current_cycle_course
  end

  def given_there_is_a_current_cycle_course
    provider = create(:provider, provider_code: "ABC")
    @current_cycle_course = published_course(
      provider:,
      name: "Geography",
      start_date: Time.zone.local(2027, 9, 1),
    )
  end

  def when_i_visit_the_previous_cycle_course_page
    visit find_course_cycle_path(
      @previous_cycle_course.provider.provider_code,
      @previous_cycle_course.course_code,
      @previous_cycle_course.recruitment_cycle_year,
    )
  end

  def when_i_visit_the_current_cycle_course_page
    visit find_course_path(
      @current_cycle_course.provider.provider_code,
      @current_cycle_course.course_code,
    )
  end

  def then_i_see_the_previous_cycle_course
    expect(page).to have_content("History")
  end

  def then_i_see_the_current_cycle_course
    expect(page).to have_content("Geography")
  end

  def and_i_see_the_previous_cycle_banner
    expect(page).to have_content("This course is from a previous recruitment cycle")
    expect(page).to have_content("You cannot apply for this course on Find")
  end

  def and_i_do_not_see_the_previous_cycle_banner
    expect(page).to have_no_content("This course is from a previous recruitment cycle")
  end

  def and_i_cannot_apply
    expect(page).to have_no_link("Apply for this course")
  end

  def and_i_can_apply
    expect(page).to have_link("Apply for this course")
  end

  def and_i_do_not_see_the_current_cycle_course
    expect(page).to have_no_content("Geography")
  end

  def then_i_see_page_not_found
    expect(page).to have_content("Page not found")
  end

  def published_course(provider:, name:, start_date:)
    create(
      :course,
      :published,
      :open,
      :with_gcse_equivalency,
      provider:,
      name:,
      course_code: "C1",
      start_date:,
    )
  end
end
