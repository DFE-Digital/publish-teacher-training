# frozen_string_literal: true

require 'rails_helper'

feature 'Searching for a school from the GIAS list' do
  before do
    given_i_am_authenticated_as_a_provider_user
    and_there_are_schools_in_the_database
  end

  scenario 'i can search for a school by query' do
    when_i_visit_the_school_search_page
    and_i_search_with_an_invalid_query
    then_i_should_see_an_error_message

    when_i_search_for_a_school_with_a_valid_query
    then_i_should_see_a_single_radio_list

    when_i_visit_the_school_search_page
    when_i_search_for_a_school_with_a_partial_query
    then_i_should_see_a_radio_list

    when_i_continue_without_selecting_a_school
    then_i_should_see_an_error_message('Select a school')
    and_i_should_still_see_the_school_i_searched_for

    when_i_select_the_school
    then_i_should_be_taken_to_the_add_school_page
    and_the_school_form_should_be_prefilled(@school_two)
  end

  private

  def and_i_go_back
    click_on 'Back'
  end

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])])
    )
  end

  def and_there_are_schools_in_the_database
    @school = create(:gias_school, name: 'Bernard')
    @school_two = create(:gias_school, name: 'School Two')
    @school_three = create(:gias_school, name: 'School Three')
  end

  def when_i_visit_the_school_search_page
    visit search_publish_provider_recruitment_cycle_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def when_i_search_for_a_school_with_a_partial_query
    fill_in 'publish-schools-search-form-query-field', with: 'sch'
    click_continue
  end

  def then_i_should_see_a_single_radio_list
    expect(page).to have_content @school.name
    expect(page).not_to have_content @school_two.name
    expect(page).not_to have_content @school_three.name
  end

  def then_i_should_see_a_radio_list
    expect(page).not_to have_content @school.name
    expect(page).to have_content @school_two.name
    expect(page).to have_content @school_three.name
  end

  def when_i_search_for_a_school_with_a_valid_query
    fill_in 'publish-schools-search-form-query-field', with: @school.name
    click_continue
  end

  def when_i_select_the_school
    choose @school_two.name
    click_continue
  end

  def then_i_should_be_taken_to_the_add_school_page
    expect(page.current_url).to include("school_id=#{@school_two.id}")
  end

  def and_the_school_form_should_be_prefilled(school)
    expect(page).to have_field('School name', with: school.name)
    expect(page).to have_field('URN', with: school.urn)

    expect(page).to have_field('Address line 1', with: school.address1)
    expect(page).to have_field('Town or city', with: school.town)
    expect(page).to have_field('Postcode', with: school.postcode)
  end

  def and_i_search_with_an_invalid_query
    fill_in 'publish-schools-search-form-query-field', with: ''
    click_continue
  end

  def then_i_should_see_an_error_message(error_message = 'Enter a school, university, college, URN or postcode')
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
    click_on 'Continue'
  end

  def provider
    @current_user.providers.first
  end
end
