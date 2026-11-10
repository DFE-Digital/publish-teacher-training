# frozen_string_literal: true

require "rails_helper"

RSpec.describe "switcher cycle" do
  before do
    Timecop.freeze(2022, 10, 12)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("ENABLE_SWITCHER").and_return("1")
    find_or_create(:recruitment_cycle, year: 2023)
    find_or_create(:recruitment_cycle, year: 2024)
  end

  scenario "Navigate to /cycle" do
    when_i_visit_switcher_cycle_page
    then_i_should_see_the_page_title
    and_i_should_see_the_page_heading
  end

  scenario "Describes each point in the recruitment cycle" do
    when_i_visit_switcher_cycle_page

    expect(page).to have_text("You can change the point in the recruitment cycle to test features.")
    expect(page).to have_text("What point in the cycle do you want to change to?")
    expect(page).to have_css("h2.govuk-heading-s", count: 2)
    expect(page).to have_css("label", text: "Find and Apply open")
    expect(page).to have_css("label .govuk-hint", text: "11 October 2022 to 19 September 2023")
    expect(page).to have_text("Candidates can find and apply for courses")
    expect(page).to have_text("Candidates can find courses, but can no longer apply for them")
    expect(page).to have_text("Candidates can no longer find or apply for courses")
    expect(page).to have_text("Candidates can find courses, but cannot apply for them yet")
    expect(page).to have_css(".govuk-radios__divider", text: "or")
    expect(page).to have_text("Same as production environment")
    expect(page).to have_button("Change recruitment cycle")
    expect(page).to have_field("Show the banner with the application deadline", visible: :all)
    expect(page).not_to have_css("h2", text: "Cycle years")
    expect(page).not_to have_css("h2", text: "Deadlines")
  end

  scenario "Update to Find open, Apply closed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("can no longer apply for them")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_the_cycle_point_is_now("apply_closed")
  end

  scenario "Find and Apply closed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("can no longer find or apply for courses")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_i_visit_the_find_homepage
    then_i_should_see_the_applications_closed_text
  end

  scenario "Find and Apply open in the next cycle" do
    when_i_visit_switcher_cycle_page
    and_i_choose_the_next_cycle_apply_option
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_the_cycle_point_is_now("apply_reopened")
  end

  scenario "Find open before Apply in the next cycle" do
    when_i_visit_switcher_cycle_page
    and_i_choose("cannot apply for them yet")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_the_cycle_point_is_now("apply_not_open_yet")
  end

  def when_i_visit_switcher_cycle_page
    visit "/cycles"
  end

  def then_i_should_see_the_page_title
    expect(page.title).to have_content "Change recruitment cycle"
  end

  def and_i_should_see_the_page_heading
    expect(find_courses_by_location_or_training_provider_page.heading).to have_content "Change recruitment cycle"
  end

  def and_i_choose(text)
    page.find(".govuk-radios__item", text:).choose
  end

  def and_i_choose_the_next_cycle_apply_option
    page.all(".govuk-radios__item", text: "Candidates can find and apply for courses").last.choose
  end

  def then_i_click_on_update_button
    page.click_link_or_button("Change recruitment cycle")
  end

  def and_i_should_see_the_success_banner
    expect(page).to have_css("h2", text: "Success")
  end

  def and_i_visit_the_find_homepage
    visit "/"
  end

  def and_the_cycle_point_is_now(value)
    expect(page).to have_checked_field(with: value)
  end

  def then_i_should_see_the_applications_closed_text
    expect(page).to have_text("Applications are currently closed but you can get ready to apply")
  end
end
