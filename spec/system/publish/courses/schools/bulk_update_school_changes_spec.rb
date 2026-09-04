# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Playing back the schools a bulk update will change", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "the schools added and removed are named on both pages" do
    given_a_course_attached_to("School 1", "School 2")
    when_i_tick("School 3")
    and_i_untick("School 1")
    and_i_continue

    then_i_am_told_i_am_adding("School 3")
    and_i_am_told_i_am_removing("School 1")

    when_i_go_on_to_review_all_courses

    then_i_am_told_i_am_adding("School 3")
    and_i_am_told_i_am_removing("School 1")
  end

  scenario "ticking every school says so rather than listing them" do
    given_a_course_attached_to("School 1")
    when_i_tick(*school_names)
    and_i_continue

    then_i_see("You are adding all schools in your list")
    and_no_schools_are_listed
  end

  # Only reachable on a course support has allowed to publish without schools:
  # any other course is stopped by the validation before it gets here.
  scenario "unticking every school says so rather than listing them" do
    given_a_course_attached_to("School 1", "School 2", exempt: true)
    when_i_untick("School 1", "School 2")
    and_i_continue

    then_i_see("You are removing all schools in your list")
    and_no_schools_are_listed
  end

  scenario "eight schools stay in the open" do
    given_a_course_attached_to("School 1")
    when_i_tick(*school_names[1, 8])
    and_i_continue

    then_i_am_told_i_am_adding(*school_names[1, 8])
    and_nothing_is_collapsed
  end

  scenario "nine schools move behind a details, and take the other half with them" do
    given_a_course_attached_to("School 1")
    when_i_tick(*school_names[1, 9])
    and_i_untick("School 1")
    and_i_continue

    then_the_collapsed_summaries_are("You are adding 9 schools", "You are removing 1 school")
  end

  scenario "nine removals collapse both halves too" do
    given_a_course_attached_to(*school_names.first(10))
    when_i_untick(*school_names[1, 9])
    and_i_tick("School 11")
    and_i_continue

    then_the_collapsed_summaries_are("You are adding 1 school", "You are removing 9 schools")
  end

  # A school taken off the provider's list while they were deciding is not
  # written either, so it is not played back.
  scenario "a school that has since left the list is not named" do
    given_a_course_attached_to("School 1")
    when_i_tick("School 2", "School 3")
    and_i_continue
    and_school_2_leaves_the_providers_list
    and_i_reload_the_page

    then_i_am_told_i_am_adding("School 3")
  end

private

  attr_reader :provider, :course

  def school_names
    @school_names ||= (1..12).map { |number| "School #{number}" }
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    school_names.each { |location_name| create(:site, :with_provider_school, provider: @provider, location_name:) }
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @provider.reload
  end

  def given_a_course_attached_to(*names, exempt: false)
    @course = create(:course, :secondary, provider:, sites: [], publish_without_schools_allowed: exempt)
    names.each do |location_name|
      provider_school = provider.schools.joins(:gias_school).find_by!(gias_school: { name: location_name })
      create(:course_school, course: @course, provider_school:, gias_school: provider_school.gias_school)
    end

    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def when_i_tick(*names)
    names.each { |name| check name }
  end
  alias_method :and_i_tick, :when_i_tick

  def when_i_untick(*names)
    names.each { |name| uncheck name }
  end
  alias_method :and_i_untick, :when_i_untick

  def and_i_continue
    publish_course_school_edit_page.submit.click
  end

  def when_i_go_on_to_review_all_courses
    choose "All courses"
    click_button "Continue to view the courses that will be updated"
  end

  def and_school_2_leaves_the_providers_list
    provider.schools.joins(:gias_school).find_by!(gias_school: { name: "School 2" }).destroy
  end

  def and_i_reload_the_page
    visit page.current_path
  end

  def then_i_am_told_i_am_adding(*names)
    expect(page).to have_content("You are updating these schools")
    expect(added_names).to eq(names)
  end

  def and_i_am_told_i_am_removing(*names)
    expect(removed_names).to eq(names)
  end

  def then_i_see(text)
    expect(page).to have_content(text)
  end

  def and_no_schools_are_listed
    expect(changes_section.all("li").map(&:text)).to be_empty
  end

  def and_nothing_is_collapsed
    expect(changes_section).to have_no_css("details")
  end

  def then_the_collapsed_summaries_are(*summaries)
    expect(changes_section.all(".govuk-details__summary-text").map(&:text)).to eq(summaries)
  end

  def changes_section
    page.find(".app-school-changes")
  end

  def added_names
    names_under(/\AYou are adding/)
  end

  def removed_names
    names_under(/\AYou are removing/)
  end

  def names_under(heading)
    node = changes_section.all("h3, .govuk-details__summary-text").find { |element| element.text.match?(heading) }
    return [] if node.nil?

    node.first(:xpath, "./following::ul[1]").all("li").map(&:text)
  end
end
