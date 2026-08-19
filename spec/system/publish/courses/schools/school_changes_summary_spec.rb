# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish - Playing back the schools being changed", :js, type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_two_of_the_five_schools_are_attached_to_the_course
    when_i_visit_the_publish_course_school_edit_page
  end

  scenario "nothing is played back until something changes" do
    then_i_see_no_summary
  end

  scenario "adding schools" do
    when_i_check("Cedar School")
    then_i_see_the_summary
    and_i_am_told_i_am_adding("Cedar School")

    when_i_check("Damson & Elm Primary School")
    and_i_am_told_i_am_adding("Cedar School", "Damson & Elm Primary School")
  end

  scenario "removing schools" do
    when_i_uncheck("Beech School")
    then_i_see_the_summary
    and_i_am_told_i_am_removing("Beech School")
  end

  scenario "adding and removing at the same time" do
    when_i_check("Cedar School")
    and_i_uncheck("Ash Academy")
    and_i_am_told_i_am_adding("Cedar School")
    and_i_am_told_i_am_removing("Ash Academy")
  end

  scenario "undoing a change takes the summary away again" do
    when_i_check("Cedar School")
    then_i_see_the_summary
    when_i_uncheck("Cedar School")
    then_i_see_no_summary
  end

  scenario "selecting every school" do
    when_i_select_all_schools
    then_i_see_the_summary
    and_i_am_told_i_am_adding_all_schools
    and_i_am_not_told_i_am_removing_anything
  end

  scenario "clearing every school" do
    when_i_select_all_schools
    and_i_unselect_all_schools
    then_i_see_the_summary
    and_i_am_told_i_am_removing_all_schools
    and_i_am_not_told_i_am_adding_anything
  end

  # The list only hides the schools a search rules out, so their ticks are still
  # in the DOM and still submitted. The play-back has to agree with what will be
  # saved, not with what happens to be on screen.
  scenario "schools hidden by a search still count" do
    when_i_search_for("Cedar")
    and_i_check("Cedar School")
    and_i_am_told_i_am_adding("Cedar School")
    and_i_am_not_told_i_am_removing_anything
  end

  # The summary is the last thing before the button, and it wants the same gap
  # above it whether it ends in a list of schools or in the one-line message.
  scenario "the button is not crowded against the summary" do
    when_i_check("Cedar School")
    then_the_gap_above_the_button_is(20)

    when_i_select_all_schools
    and_i_unselect_all_schools
    and_i_am_told_i_am_removing_all_schools
    then_the_gap_above_the_button_is(20)
  end

private

  def attached_schools
    ["Ash Academy", "Beech School"]
  end

  # Three unattached, so that adding two of them is not also "all of them".
  def unattached_schools
    ["Cedar School", "Damson & Elm Primary School", "Elder Grove School"]
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)

    (attached_schools + unattached_schools).each do |location_name|
      create(:site, :with_provider_school, provider: @provider, location_name:)
    end

    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @provider.reload
  end

  def and_two_of_the_five_schools_are_attached_to_the_course
    @course = create(:course, provider:, sites: [])

    attached_schools.each do |location_name|
      provider_school = provider.schools.joins(:gias_school).find_by!(gias_school: { name: location_name })
      create(:course_school, course:, provider_school:, gias_school: provider_school.gias_school)
    end
  end

  def when_i_visit_the_publish_course_school_edit_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def when_i_check(school_name)
    check school_name
  end
  alias_method :and_i_check, :when_i_check

  def when_i_uncheck(school_name)
    uncheck school_name
  end
  alias_method :and_i_uncheck, :when_i_uncheck

  def when_i_select_all_schools
    check "Select all schools"
  end

  def and_i_unselect_all_schools
    uncheck "Select all schools"
  end

  def when_i_search_for(query)
    fill_in "Search for a school in the list", with: query
    click_button "Search"
  end

  def then_i_see_the_summary
    expect(publish_course_school_edit_page).to have_changes_summary
    expect(publish_course_school_edit_page.changes_summary).to have_content("You are updating these schools")
  end

  def then_i_see_no_summary
    expect(publish_course_school_edit_page).to have_no_changes_summary
  end

  def and_i_am_told_i_am_adding(*school_names)
    expect(publish_course_school_edit_page.added).to have_content(
      "You are adding #{school_names.one? ? '1 school' : "#{school_names.size} schools"}:",
    )
    expect(publish_course_school_edit_page.added_school_names).to eq(school_names)
  end

  def and_i_am_told_i_am_removing(*school_names)
    expect(publish_course_school_edit_page.removed).to have_content(
      "You are removing #{school_names.one? ? '1 school' : "#{school_names.size} schools"}:",
    )
    expect(publish_course_school_edit_page.removed_school_names).to eq(school_names)
  end

  def and_i_am_told_i_am_adding_all_schools
    expect(publish_course_school_edit_page.added).to have_content("You are adding all schools in your list")
  end

  def and_i_am_told_i_am_removing_all_schools
    expect(publish_course_school_edit_page.removed).to have_content("You are removing all schools in your list")
  end

  def and_i_am_not_told_i_am_removing_anything
    expect(publish_course_school_edit_page.changes_summary).to have_no_content("You are removing")
  end

  def and_i_am_not_told_i_am_adding_anything
    expect(publish_course_school_edit_page.changes_summary).to have_no_content("You are adding")
  end

  def then_the_gap_above_the_button_is(pixels)
    gap = page.evaluate_script(<<~JS)
      (() => {
        const summary = document.querySelector('.app-schools-changes')
        const button = document.querySelector('button.govuk-button[type="submit"]')

        return button.getBoundingClientRect().top - summary.getBoundingClientRect().bottom
      })()
    JS

    expect(gap).to eq(pixels)
  end

  attr_reader :course, :provider
end
