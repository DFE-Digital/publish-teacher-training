require "rails_helper"

feature "switcher cycle" do
  scenario "Navigate to /find/cycle" do
    when_i_visit_switcher_cycle_page
    then_i_should_see_the_page_title
    and_i_should_see_the_page_heading
  end

  scenario "Mid cycle and deadlines should be displayed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("Mid cycle and deadlines should be displayed")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_i_visit_results_page
    and_i_see_deadline_banner("Apply now to get on a course starting in the 2023 to 2024 academic year")
  end

  scenario "Update to Apply 1 deadline has passed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("Apply 1 deadline has passed")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_i_visit_results_page
    and_i_see_deadline_banner("You can continue to view and apply for courses starting in")
  end

  scenario "Update to Apply 2 deadline has passed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("Apply 2 deadline has passed")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_i_visit_results_page
    and_i_see_deadline_banner("Courses are currently closed but you can get your application ready")
  end

  scenario "Find has closed" do
    when_i_visit_switcher_cycle_page
    and_i_choose("Find has closed")
    then_i_click_on_update_button
    and_i_should_see_the_success_banner
    and_i_visit_the_find_homepage
    then_i_should_see_the_applications_closed_text
  end

  # scenario "Find has reopened" do
  #   when_i_visit_switcher_cycle_page
  #   and_i_choose("Find has reopened")
  #   then_i_click_on_update_button
  #   and_i_should_see_the_success_banner
  #   and_i_visit_results_page
  #   and_i_do_not_see_deadline_banner
  # end

  def when_i_visit_switcher_cycle_page
    visit "/find/cycles"
  end

  def then_i_should_see_the_page_title
    expect(page.title).to have_content "Recruitment cycles"
  end

  def and_i_should_see_the_page_heading
    expect(courses_by_location_or_training_provider_page.heading).to have_content "Recruitment cycles"
  end

  def and_i_choose(option)
    page.choose(option)
  end

  def then_i_click_on_update_button
    page.click_on("Update point in recruitment cycle")
  end

  def and_i_should_see_the_success_banner
    expect(page).to have_selector("h2", text: "Success")
  end

  def and_i_visit_results_page
    visit "/find/results"
  end

  def and_i_visit_the_find_homepage
    visit "/find"
  end

  def and_i_see_deadline_banner(banner_text)
    expect(page).to have_selector(".govuk-notification-banner__content", text: banner_text)
  end

  def then_i_should_see_the_applications_closed_text
    expect(page).to have_text("Applications are currently closed but you can get ready to apply")
  end
end
