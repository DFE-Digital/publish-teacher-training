# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Publish - Reviewing the courses a placement school change will update", type: :system do
  before do
    given_i_am_authenticated_as_a_provider_user
  end

  scenario "only this course never asks for a review" do
    given_a_fee_paying_course_and_another_like_it
    when_i_add_a_school
    and_i_choose("Only this course - #{course.name_and_code}")
    and_i_continue

    then_i_am_on_the_basic_details_page
  end

  scenario "the courses that will be updated are listed" do
    given_a_fee_paying_course_and_another_like_it
    and_a_salaried_course_exists
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue

    then_i_see_the_scope("All fee-paying courses")
    and_the_table_lists(course, other_course)
    and_the_table_does_not_list(salaried_course)
    and_the_button_offers_to_update(2)
  end

  scenario "the table shows each course's status" do
    given_a_fee_paying_course_and_another_like_it
    and_the_other_course_is_published_and_closed
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue

    then_i_see_the_statuses("Draft", "Closed")
  end

  # Which accredited provider ratifies a course makes no difference to which
  # schools it trains in, so they are counted and listed together.
  scenario "courses ratified by different accredited providers are listed together" do
    given_a_fee_paying_course_and_another_like_it
    and_the_other_course_is_ratified_by_someone_else
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue

    and_the_table_lists(course, other_course)
  end

  scenario "all courses lists them too" do
    given_a_fee_paying_course_and_another_like_it
    and_a_salaried_course_exists
    when_i_add_a_school
    and_i_choose("All courses")
    and_i_continue

    and_the_table_lists(course, other_course, salaried_course)
    and_the_button_offers_to_update(3)
  end

  scenario "confirming applies the change to every course listed" do
    given_a_fee_paying_course_and_another_like_it
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue
    and_i_confirm

    then_i_am_on_the_basic_details_page
    and_i_am_told_the_schools_were_updated_on(2)
    and_the_course_has("Ash Academy", "Beech School", "Cedar School")
    and_the_other_course_has("Ash Academy", "Cedar School")
  end

  scenario "cancelling changes nothing" do
    given_a_fee_paying_course_and_another_like_it
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue
    and_i_cancel

    then_i_am_on_the_basic_details_page
    and_the_course_has("Ash Academy", "Beech School")
    and_the_other_course_has("Ash Academy")
  end

  scenario "going back keeps the answer that was chosen" do
    given_a_fee_paying_course_and_another_like_it
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue
    and_i_go_back

    then_the_chosen_option_is("All fee-paying courses")
  end

  scenario "the change cannot be confirmed twice" do
    given_a_fee_paying_course_and_another_like_it
    when_i_add_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue
    review_page = page.current_path
    and_i_confirm
    and_i_return_to(review_page)

    then_i_am_told_my_selection_has_expired
  end

  describe "when some courses cannot be updated" do
    before do
      given_a_fee_paying_course_and_another_like_it
      and_the_other_course_has_only_the_school_being_removed
      when_i_remove_a_school
      and_i_choose("All fee-paying courses")
      and_i_continue
    end

    scenario "they are named under a warning" do
      then_i_am_warned_that_some_courses_will_not_be_updated
      and_the_reason_given_is(
        "The schools that you are removing are the only placement schools attached to these courses.",
        "These courses must have at least one school attached.",
      )
      and_the_courses_that_will_not_be_updated_are(other_course)
    end

    scenario "they are not counted and not changed" do
      and_the_button_offers_to_update(1)
      and_i_confirm

      and_i_am_told_the_schools_were_updated_on(1)
      and_the_course_has("Beech School")
      and_the_other_course_has("Ash Academy")
    end
  end

  scenario "nothing is set aside when schools are being added" do
    given_a_fee_paying_course_and_another_like_it
    and_the_other_course_has_only_the_school_being_removed
    when_i_swap_a_school
    and_i_choose("All fee-paying courses")
    and_i_continue

    then_i_am_not_warned_that_some_courses_will_not_be_updated
    and_the_button_offers_to_update(2)
  end

private

  attr_reader :provider, :course, :other_course, :salaried_course

  def school_names
    ["Ash Academy", "Beech School", "Cedar School"]
  end

  def given_i_am_authenticated_as_a_provider_user
    @provider = create(:provider)
    school_names.each { |location_name| create(:site, :with_provider_school, provider: @provider, location_name:) }
    given_i_am_authenticated(user: create(:user, providers: [@provider]))
    @provider.reload
  end

  def given_a_fee_paying_course_and_another_like_it
    @course = create(:course, :secondary, provider:, funding: :fee, sites: [], name: "First")
    attach("Ash Academy", to: @course)
    attach("Beech School", to: @course)

    @other_course = create(:course, :secondary, provider:, funding: :fee, sites: [], name: "Second")
    attach("Ash Academy", to: @other_course)
  end

  def and_a_salaried_course_exists
    @salaried_course = create(:course, :secondary, provider:, funding: :salary, sites: [], name: "Third")
    attach("Ash Academy", to: @salaried_course)
  end

  def and_the_other_course_is_published_and_closed
    other_course.enrichments << build(:course_enrichment, :published)
    other_course.update!(application_status: :closed)
  end

  def and_the_other_course_is_ratified_by_someone_else
    other_course.update!(accrediting_provider: create(:accredited_provider))
  end

  def and_the_other_course_has_only_the_school_being_removed
    other_course.schools.destroy_all
    attach("Ash Academy", to: other_course)
  end

  def attach(location_name, to:)
    provider_school = provider.schools.joins(:gias_school).find_by!(gias_school: { name: location_name })
    create(:course_school, course: to, provider_school:, gias_school: provider_school.gias_school)
  end

  def visit_the_placement_schools_page
    publish_course_school_edit_page.load(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
      course_code: course.course_code,
    )
  end

  def when_i_add_a_school
    visit_the_placement_schools_page
    check "Cedar School"
    publish_course_school_edit_page.submit.click
  end

  def when_i_remove_a_school
    visit_the_placement_schools_page
    uncheck "Ash Academy"
    publish_course_school_edit_page.submit.click
  end

  def when_i_swap_a_school
    visit_the_placement_schools_page
    uncheck "Ash Academy"
    check "Cedar School"
    publish_course_school_edit_page.submit.click
  end

  def and_i_choose(label)
    choose label
  end

  def and_i_continue
    click_button "Continue to view the courses that will be updated"
  end

  def and_i_confirm
    Sidekiq::Testing.inline! { click_button(page.find("button[type='submit']").text) }
  end

  def and_i_cancel
    click_link "Cancel"
  end

  def and_i_go_back
    click_link "Back"
  end

  def and_i_return_to(path)
    visit path
  end

  def then_i_see_the_scope(label)
    expect(page).to have_content("You are updating these courses:")
    expect(page).to have_css("li", text: label)
  end

  def and_the_table_lists(*courses)
    courses.each { |a_course| expect(page).to have_css("td", text: a_course.name_and_code) }
  end

  def and_the_table_does_not_list(a_course)
    expect(page).to have_no_css("td", text: a_course.name_and_code)
  end

  def then_i_see_the_statuses(*labels)
    expect(page.all(".app-table--courses__status .govuk-tag").map(&:text)).to match_array(labels)
  end

  def and_the_button_offers_to_update(count)
    expect(page).to have_button("Update placement schools on #{count} #{'course'.pluralize(count)}")
  end

  def then_the_chosen_option_is(label)
    expect(page).to have_checked_field(label)
  end

  def then_i_am_warned_that_some_courses_will_not_be_updated
    expect(page).to have_content("These courses will not be updated")
  end

  def then_i_am_not_warned_that_some_courses_will_not_be_updated
    expect(page).to have_no_content("These courses will not be updated")
  end

  def and_the_reason_given_is(*sentences)
    expect(page).to have_content("Why will these courses not be updated?")
    sentences.each { |sentence| expect(page).to have_content(sentence) }
  end

  def and_the_courses_that_will_not_be_updated_are(*courses)
    courses.each { |a_course| expect(page).to have_css("li", text: a_course.name_and_code) }
  end

  def then_i_am_on_the_basic_details_page
    expect(page).to have_current_path(
      details_publish_provider_recruitment_cycle_course_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
        course.course_code,
      ),
    )
  end

  def and_i_am_told_the_schools_were_updated_on(count)
    expect(page).to have_content("Schools updated on #{count} #{'course'.pluralize(count)}")
  end

  def then_i_am_told_my_selection_has_expired
    expect(page).to have_content("Your school selection has expired")
  end

  def and_the_course_has(*names)
    expect(attached_names(course)).to match_array(names)
  end

  def and_the_other_course_has(*names)
    expect(attached_names(other_course)).to match_array(names)
  end

  def attached_names(a_course)
    a_course.reload.schools.joins(:gias_school).pluck("gias_school.name")
  end
end
