# frozen_string_literal: true

require "rails_helper"
require_relative "provider_school_helper"

feature "Adding a provider's schools" do
  include ProviderSchoolHelper
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_are_gias_schools
    when_i_visit_the_schools_page
    then_i_should_see_a_list_of_schools

    given_i_see_the_schools_guidance_text
    when_i_click_add_a_school
    then_i_am_on_the_school_search_page
  end

  scenario "with duplicate school" do
    when_i_search_with_an_duplicate_query
    then_i_should_see_duplicate_school_options

    when_i_choose_the_duplicate_school_i_want_to_add
    and_i_click_add_school

    then_i_see_the_school_is_added_message
  end

  scenario "with new school" do
    when_i_search_with_an_empty_query
    then_i_should_see_an_error_message

    when_i_search_with_an_unmatched_query
    then_i_should_see_a_no_results_message

    then_i_click_change_your_search

    when_i_search_with_an_partial_query
    then_i_should_see_school_options

    when_i_choose_the_school_i_want_to_add
    then_i_see_the_confirmation_page

    when_i_click_add_school
    then_i_see_a_confirmation_message
  end

  def and_there_are_gias_schools
    @gias_school = create(:gias_school, {
      urn: "123456",
      name: "Distinct School",
      address1: "123 Fake Street",
      town: "Newtown",
      postcode: "RD9 0AN",
    })
  end

  def given_i_see_the_schools_guidance_text
    expect(page).to have_text("Add the schools you can offer placements in. A placement school is where candidates will go to get classroom experience.", normalize_ws: true)
    expect(page).to have_text("Your courses will not appear in candidate’s location searches if you do not add placement schools to them.", normalize_ws: true)
    expect(page).to have_link("Find out more about why you should add school placement locations", href: "https://www.publish-teacher-training-courses.service.gov.uk/how-to-use-this-service/add-schools-and-study-sites")
    expect(page).to have_text("Add placement schools here, then attach them to any of your courses from the ‘Basic details’ tab on each course page.", normalize_ws: true)
  end

  def when_i_click_add_a_school
    publish_schools_index_page.add_school.click
  end

  def then_i_am_on_the_school_search_page
    expect(page).to have_current_path(search_publish_provider_recruitment_cycle_schools_path(recruitment_cycle_year: Settings.current_recruitment_cycle_year, provider_code: provider.provider_code))
  end

  def when_i_search_with_an_empty_query
    fill_in "Enter URN or school", with: ""
    click_link_or_button "Continue"
  end

  def then_i_should_see_an_error_message
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem")
      expect(page).to have_content("Enter a URN (unique reference number) or school name")
    end
  end

  def then_i_see_the_school_is_added_message
    within(".govuk-error-summary") do
      expect(page).to have_content("There is a problem")
      expect(page).to have_content("This school has already been added")
    end
  end

  def when_i_search_with_an_unmatched_query
    fill_in "Enter URN or school", with: "zzz"
    click_link_or_button "Continue"
  end

  def then_i_should_see_a_no_results_message
    expect(page).to have_content("No results found for ‘zzz’")
  end

  def when_i_search_with_an_duplicate_query
    fill_in "Enter URN or school", with: provider.sites.first.location_name
    click_link_or_button "Continue"
  end

  def then_i_click_change_your_search
    click_link_or_button "Change your search"
  end

  def when_i_search_with_an_partial_query
    fill_in "Enter URN or school", with: "Dis"
    click_link_or_button "Continue"
  end

  def then_i_should_see_school_options
    expect(page).to have_content("1 result found for ‘Dis’")
  end

  def then_i_should_see_duplicate_school_options
    expect(page).to have_content("1 result found for ‘#{provider.sites.first.location_name}’")
  end

  def when_i_choose_the_duplicate_school_i_want_to_add
    choose provider.sites.first.location_name
    click_link_or_button "Continue"
  end

  def when_i_choose_the_school_i_want_to_add
    choose @gias_school.name
    click_link_or_button "Continue"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Add school")
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("School NameDistinct School")
    expect(page).to have_content("URN123456")
    expect(page).to have_content("Address 123 Fake Street Newtown RD9 0AN", normalize_ws: true)
  end

  def then_i_see_a_confirmation_message
    within(".govuk-notification-banner--success") do
      expect(page).to have_content("School added")
    end
  end

  def and_i_click_add_school
    click_link_or_button "Add school"
  end
  alias_method :when_i_click_add_school, :and_i_click_add_school

  def and_the_school_is_added
    expect(publish_schools_index_page.schools.size).to eq(2)
    expect(publish_schools_index_page.schools.last.name).to have_text("Some place")
  end
end
