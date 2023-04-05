# frozen_string_literal: true

require 'rails_helper'

feature 'Searching for a school from the GIAS list' do
  before do
    allow(Settings.features).to receive(:gias_search).and_return(true)
    given_i_am_authenticated_as_a_provider_user
    and_there_are_schools_in_the_database
  end

  scenario 'i can search for a school by query' do
    when_i_visit_the_school_search_page
    i_search_for_a_school
    then_i_should_see_the_schools_i_searched_for
    when_i_select_a_school
    then_i_should_be_taken_to_the_add_school_page
  end

  scenario 'i cannot search without a valid query' do
    when_i_visit_the_school_search_page
    and_i_search_with_an_invalid_query
    then_i_should_see_an_error_message
  end

  private

  def given_i_am_authenticated_as_a_provider_user
    given_i_am_authenticated(
      user: create(:user, providers: [create(:provider, sites: [build(:site)])])
    )
  end

  def and_there_are_schools_in_the_database
    @schools = create_list(:gias_school, 3)
  end

  def when_i_visit_the_school_search_page
    visit search_publish_provider_recruitment_cycle_schools_path(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  def i_search_for_a_school
    fill_in 'Enter a school, university, college, URN or postcode', with: @schools.first.name
    click_on 'Continue'
  end

  def then_i_should_see_the_schools_i_searched_for
    expect(page).to have_content(@schools.first.name)
  end

  def when_i_select_a_school
    choose @schools.first.name
    click_on 'Continue'
  end

  def then_i_should_be_taken_to_the_add_school_page
    expect(page).to have_content('Add school')
    expect(page.current_url).to include("school_id=#{@schools.first.id}")
  end

  def and_i_search_with_an_invalid_query
    fill_in 'Enter a school, university, college, URN or postcode', with: ''
    click_on 'Continue'
  end

  def then_i_should_see_an_error_message
    expect(page).to have_content('Enter a school, university, college, URN or postcode')
  end

  def provider
    @current_user.providers.first
  end
end
