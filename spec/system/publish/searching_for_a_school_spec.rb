# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Searching for a school from the GIAS list" do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_are_schools_in_the_database
  end

  scenario "i can search for a school by query" do
    when_i_visit_the_school_search_page
    and_i_search_with_an_invalid_query
    then_i_should_see_an_error_message

    when_i_search_for_a_school_with_a_valid_query
    then_i_should_see_a_single_radio_list

    when_i_visit_the_school_search_page
    when_i_search_for_a_school_with_a_partial_query
    then_i_should_see_a_radio_list

    when_i_continue_without_selecting_a_school
    then_i_should_see_an_error_message("Select a school")
    and_i_should_still_see_the_school_i_searched_for

    when_i_select_the_school
    then_i_should_be_taken_to_the_add_school_page
  end

  scenario "i can select a school using the autocomplete", :js do
    when_i_visit_the_school_search_page
    and_i_type_a_school_name_into_the_autocomplete
    then_i_see_the_school_in_the_autocomplete_suggestions
    when_i_choose_the_school_from_the_autocomplete_suggestions
    and_i_continue
    then_i_am_taken_to_the_check_page_for(@school)
  end

private

  def and_i_type_a_school_name_into_the_autocomplete
    fill_in "Enter URN or school", with: "Northgate"
  end

  def then_i_see_the_school_in_the_autocomplete_suggestions
    expect(page).to have_css(autocomplete_listbox_selector, text: @school.name)
  end

  def when_i_choose_the_school_from_the_autocomplete_suggestions
    page.find(autocomplete_listbox_selector, text: @school.name).click
  end

  def and_i_continue
    click_continue
  end

  def then_i_am_taken_to_the_check_page_for(school)
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/schools/check?school_id=#{school.id}")
  end

  def autocomplete_listbox_selector
    "#publish-providers-schools-search-form-query-field__listbox li"
  end

  def and_i_go_back
    click_link_or_button "Back"
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])]),
    )
  end

  def and_there_are_schools_in_the_database
    @school = create(:gias_school, name: "Northgate Academy", urn: "466415", postcode: "NW1 5WS", town: "Damonmouth")
    @school_two = create(:gias_school, name: "School Two")
    @school_three = create(:gias_school, name: "School Three")
  end

  def when_i_visit_the_school_search_page
    visit search_publish_provider_recruitment_cycle_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  def when_i_search_for_a_school_with_a_partial_query
    fill_in "Enter URN or school", with: "sch"
    click_continue
  end

  def then_i_should_see_a_single_radio_list
    expect(page).to have_content @school.name
    expect(page).to have_no_content @school_two.name
    expect(page).to have_no_content @school_three.name
  end

  def then_i_should_see_a_radio_list
    expect(page).to have_no_content @school.name
    expect(page).to have_content @school_two.name
    expect(page).to have_content @school_three.name
  end

  def when_i_search_for_a_school_with_a_valid_query
    fill_in "Enter URN or school", with: @school.name
    click_continue
  end

  def when_i_select_the_school
    choose @school_two.name
    click_continue
  end

  def then_i_should_be_taken_to_the_add_school_page
    expect(page).to have_current_path("/publish/organisations/#{provider.provider_code}/#{Find::CycleTimetable.current_year}/schools/check?school_id=#{@school_two.id}")
  end

  def and_i_search_with_an_invalid_query
    fill_in "Enter URN or school", with: ""
    click_continue
  end

  def then_i_should_see_an_error_message(error_message = "Enter a URN (unique reference number) or school name")
    expect(page).to have_content(error_message)
  end

  def when_i_continue_without_selecting_a_school
    click_continue
  end

  def and_i_should_still_see_the_school_i_searched_for
    expect(page).to have_content(@school_two.name)
    expect(page).to have_content(@school_three.name)
  end

  def click_continue
    click_link_or_button "Continue"
  end

  def provider
    @current_user.providers.first
  end
end
